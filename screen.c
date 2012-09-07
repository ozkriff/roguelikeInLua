/* See LICENSE file for copyright and license details */

#include <assert.h>
#include <stdio.h>
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define SCREEN "Screen"

/* start from 1 -> translate numbers when called from Lua. */
/* Tile's size = 25px X 25px
 * space between tiles = 2px
 */

/* NOTE: Don't forget to change in lua modules too */
typedef enum {
  CHAR_ARROW_UP = 1,
  CHAR_ARROW_UP_RIGHT = 2,
  CHAR_ARROW_RIGHT = 3,
  CHAR_ARROW_DOWN_RIGHT = 4,
  CHAR_ARROW_DOWN = 5,
  CHAR_ARROW_DOWN_LEFT = 6,
  CHAR_ARROW_LEFT = 7,
  CHAR_ARROW_UP_LEFT = 8,
  CHAR_Q = 9,
  CHAR_Z = 10,
  CHAR_AT = 11, /* '@' */
  CHAR_POINT = 12, /* '.' */
  CHAR_HASH = 13 /* '#' */
} CharacterCode;

typedef struct {
  SDL_Surface *bitmap;
  int w, h;
} Font;

typedef struct Screen {
  SDL_Surface *screen;
  /* characters; See CharacterCode enum */
  SDL_Surface *characters[128];
  /* map's offset */
  int offset_x;
  int offset_y;
  int cursor_x;
  int cursor_y;
  Font font;
  struct {
    Uint32 red;
    Uint32 black;
    Uint32 green;
    Uint32 blue;
    Uint32 white;
    Uint32 grey;
    Uint32 dark_grey;
  } colors;
} Screen;

static void draw_pixel32(
    SDL_Surface *surf, int x, int y, Uint32 pixel)
{
  Uint32 *pixels = (Uint32 *)surf->pixels;
  if(x >= 0 && y >= 0 && x < surf->w && y < surf->h)
    pixels[ (y * surf->w) + x ] = pixel;
}

static void swap_int(int *a, int *b) {
  int tmp = *a;
  *a = *b;
  *b = tmp;
}

/* en.wikipedia.org/wiki/Bresenham's_line_algorithm */

static void bresenham_line(
    SDL_Surface *surf,
    int ax, int ay, int bx, int by,
    Uint32 color)
{
  int deltax, deltay;
  int error, y, ystep, x;
  int is_steep; /* boolean */
  is_steep = abs(by - ay) > abs(bx - ax);
  if (is_steep) {
    swap_int(&ax, &ay);
    swap_int(&bx, &by);
  }
  if (ax > bx) {
    swap_int(&ax, &bx);
    swap_int(&ay, &by);
  }
  deltax = bx - ax;
  deltay = abs(by - ay);
  error = deltax >> 1;
  y = ay;
  ystep = (ay < by) ? 1 : -1;
  for (x = ax; x <= bx; x++) {
    if (!is_steep) {
      draw_pixel32(surf, x, y, color);
    } else {
      draw_pixel32(surf, y, x, color);
    }
    error -= deltay;
    if (error < 0) {
      y += ystep;
      error += deltax;
    }
  }
}

static void draw_bg(Screen *screen, Uint32 color) {
  SDL_FillRect(screen->screen, NULL, color);
}

static void draw_image(Screen *screen, int x, int y,
    SDL_Surface *surface)
{
  SDL_Rect dest;
  dest.x = x;
  dest.y = y;
  dest.w = surface->w;
  dest.h = surface->h;
  SDL_BlitSurface(surface, NULL, screen->screen, &dest);
}

static void init_colors(Screen *screen) {
  SDL_PixelFormat *f = screen->screen->format; /* shortcut */
  screen->colors.red = SDL_MapRGBA(f, 255, 0, 0, 255);
  screen->colors.green = SDL_MapRGBA(f, 0, 255, 0, 255);
  screen->colors.blue = SDL_MapRGBA(f, 0, 0, 255, 255);
  screen->colors.white = SDL_MapRGBA(f, 255, 255, 255, 255);
  screen->colors.black = SDL_MapRGBA(f, 0, 0, 0, 255);
  screen->colors.grey = SDL_MapRGBA(f, 150, 150, 150, 255);
  screen->colors.dark_grey = SDL_MapRGBA(f, 80, 80, 80, 255);
}

static SDL_Surface* loadimg(const char *str) {
  SDL_Surface *original = IMG_Load(str);
  SDL_Surface *optimized;
  if (!original) {
    /* die("ui_sdl: loadimg(): No file '%s'\n", str); */
    printf("loadimg(): No file '%s'\n", str);
    exit(1);
  }
  optimized = SDL_DisplayFormatAlpha(original);
  SDL_FreeSurface(original);  
  return optimized;
}

#define DATA(x) x

static void init_characters(Screen *screen) {
  screen->characters[CHAR_ARROW_UP]
      = loadimg(DATA("img/arrows/up.png"));
  screen->characters[CHAR_ARROW_UP_RIGHT]
      = loadimg(DATA("img/arrows/up_right.png"));
  screen->characters[CHAR_ARROW_RIGHT]
      = loadimg(DATA("img/arrows/right.png"));
  screen->characters[CHAR_ARROW_DOWN_RIGHT]
      = loadimg(DATA("img/arrows/down_right.png"));
  screen->characters[CHAR_ARROW_DOWN]
      = loadimg(DATA("img/arrows/down.png"));
  screen->characters[CHAR_ARROW_DOWN_LEFT]
      = loadimg(DATA("img/arrows/down_left.png"));
  screen->characters[CHAR_ARROW_LEFT]
      = loadimg(DATA("img/arrows/left.png"));
  screen->characters[CHAR_ARROW_UP_LEFT]
      = loadimg(DATA("img/arrows/up_left.png"));
  screen->characters[CHAR_AT]
      = loadimg(DATA("img/chars/at.png"));
  screen->characters[CHAR_Q]
      = loadimg(DATA("img/chars/q.png"));
  screen->characters[CHAR_Z]
      = loadimg(DATA("img/chars/z.png"));
  screen->characters[CHAR_HASH]
      = loadimg(DATA("img/chars/hash.png"));
  screen->characters[CHAR_POINT]
      = loadimg(DATA("img/chars/point.png"));
}

static Screen* to_screen(lua_State *L, int index) {
  Screen *screen = (Screen*)lua_touserdata(L, index);
  assert(screen);
  return screen;
}

static Screen* check_screen(lua_State *L, int index) {
  Screen *screen;
  luaL_checktype(L, index, LUA_TUSERDATA);
  screen = (Screen*)luaL_checkudata(L, index, SCREEN);
  assert(screen);
  return screen;
}

static Screen* push_screen(lua_State *L) {
  Screen *screen = (Screen*)lua_newuserdata(L, sizeof(Screen));
  memset(screen, 0, sizeof(Screen));
  luaL_getmetatable(L, SCREEN);
  lua_setmetatable(L, -2);
  return screen;
}

static int screen_new(lua_State *L) {
  /* TODO */
#if 0
  /* int x = luaL_optint(L, 1, 0);
  int y = luaL_optint(L, 2, 0); */
  Screen *screen = push_screen(L);
  screen->x = x;
  screen->y = y;
  return 1;
#else
  Screen *screen = push_screen(L);
  (void)screen; /* TODO */
  return 1;
#endif
}

typedef struct {
  int x, y;
} Vec2i;

/* TODO */
static Vec2i get_rendered_size(Font *font, char *s) {
  Vec2i size;
  int y = font->h;
  int x = 0;
  int max_x = 0;
  int i;
  size.y = font->h;
  for (i = 0; s[i] != '\0'; i++) {
    if (s[i] == '\n') {
      y += font->h; 
      x = 0;
    } else {
      x += font->w;
      if (x > max_x) {
        max_x = x;
      }
    }
  }
  size.x = max_x;
  size.y = y;
  return(size);
}

/* Go through the text.
 * If meet ' ' then move over.
 * If meet '\n' then move down and move back.
 * If meet normal character then show the character
 * and move over the width of the character.
 */
static void render_text(
    SDL_Surface *dest, Font *font, const char *s, Vec2i pos)
{
  Vec2i cursor = pos;
  int i;
  if (font->bitmap == NULL) {
    return;
  }
  for (i = 0; s[i] != '\0'; i++) {
    if (s[i] == ' ') {
      cursor.x += font->w; 
    } else if(s[i] == '\n') {
      cursor.y += font->h; 
      cursor.x = pos.x; 
    } else {
      int n = s[i] - 32;
      SDL_Rect clip, offset;
      clip.x = (Sint16)font->w * (n % 16);
      clip.y = (Sint16)font->h * (n / 16);
      clip.w = (Sint16)font->w;
      clip.h = (Sint16)font->h;
      offset.x = (Sint16)cursor.x;
      offset.y = (Sint16)cursor.y;
      SDL_BlitSurface(font->bitmap, &clip, dest, &offset);
      cursor.x += font->w;
    }
  }
}

static Font build_font(SDL_Surface *surface, int w, int h) {
  Font font;
  font.bitmap = surface;
  font.w = w;
  font.h = h;
  return font;
}

static int screen_init(lua_State *L) {
  Screen *screen;
  int w, h, bpp;
  screen = check_screen(L, 1);
  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    fprintf(stderr,
        "Couldn't initialize SDL: %s\n",
        SDL_GetError());
    /* TODO: Don't die, just return error */
    exit(1);
  }
  h = lua_tointeger(L, 2);
  w = lua_tointeger(L, 3);
  bpp = lua_tointeger(L, 4);
  screen->screen = SDL_SetVideoMode(
      w, h, bpp, SDL_RESIZABLE);
  SDL_WM_SetCaption("Marauder_rl", NULL);
  if (!screen) {
    fprintf(stderr, "SDL_SetVideoMode() error: %s\n",
        SDL_GetError());
    exit(1);
  }
  IMG_Init(IMG_INIT_PNG);
  init_colors(screen);
  init_characters(screen);
  screen->font = build_font(loadimg("img/font_8x12.png"), 8, 12);
  return 0;
}

static int screen_close(lua_State *L) {
  Screen *screen;
  screen = check_screen(L, -1);
  SDL_Quit();
  (void)screen;
  /* TODO: free memory */
  return 0;
}

static int screen_move(lua_State *L) {
  Screen *screen;
  int args_count = lua_gettop(L);
  assert(args_count == 3);
  screen = check_screen(L, 1);
  assert(lua_isnumber(L, 2) && lua_isnumber(L, 3));
  /* TODO: assert() > 0 */
  screen->cursor_x = lua_tointeger(L, 3) - 1;
  screen->cursor_y = lua_tointeger(L, 2) - 1;
#if 0
  printf("cursor = {x = %d, y = %d}\n",
      screen->cursor_x,
      screen->cursor_y);
#endif
  assert(screen->cursor_x >= 0);
  assert(screen->cursor_y >= 0);
  return 0;
}

static int screen_printf(lua_State *L) {
  Screen *screen;
  SDL_Surface *surface;
  int sx, sy;
  int args_count = lua_gettop(L);
  int char_code;
  assert(args_count == 2);
  screen = check_screen(L, 1);
  char_code = lua_tointeger(L, 2);
  surface = screen->characters[char_code];
#if 1
  sx = screen->offset_x + 25 * screen->cursor_x;
  sy = screen->offset_y + 25 * screen->cursor_y;
#else
  sx = screen->offset_x + 22 * screen->cursor_x;
  sy = screen->offset_y + 22 * screen->cursor_y;
#endif
  draw_image(screen, sx, sy, surface);
  return 0;
}

/* TODO: Add color */
static int screen_clear(lua_State *L) {
  Screen *screen;
  screen = check_screen(L, -1);
  draw_bg(screen, screen->colors.grey);
  return 0;
}

static int screen_refresh(lua_State *L) {
  Screen *screen;
  screen = check_screen(L, -1);
  SDL_Flip(screen->screen);
  return 0;
}

static int screen_get_char(lua_State *L) {
  Screen *screen;
  int char_code = -1;
  SDL_Event e;
  screen = check_screen(L, -1);
  while (char_code == -1) {
    while (SDL_PollEvent(&e)) {
      switch (e.type) {
        case SDL_KEYUP: {
          char_code = e.key.keysym.sym;
          break;
        }
#if 1
        /* TODO: Move out here? */
        case SDL_QUIT: {
          /* done = true; */
          printf("case SDL_QUIT\n");
          exit(0);
          break;
        }
        case SDL_VIDEORESIZE: {
          screen->screen = SDL_SetVideoMode(
              e.resize.w, e.resize.h,
              32, SDL_RESIZABLE);
          /* TODO: Redraw */
          break;
        }
#endif
      }
    }
    SDL_Delay(10);
  }
  assert(char_code > 0);
  assert(char_code < 128);
  lua_pushinteger(L, char_code);
  return 1;
}

static int screen_delay(lua_State *L) {
  Screen *screen;
  int args_count = lua_gettop(L);
  int time;
  (void)screen;
  assert(args_count == 2);
  screen = check_screen(L, 1);
  time = lua_tointeger(L, 2);
  SDL_Delay(time);
  return 0;
}

/* TODO: Color */
static int screen_line(lua_State *L) {
  Screen *screen;
  int x0, y0, x1, y1;
  int args_count = lua_gettop(L);
  assert(args_count == 5);
  screen = check_screen(L, 1);
  assert(lua_isnumber(L, 2)
      && lua_isnumber(L, 3)
      && lua_isnumber(L, 4)
      && lua_isnumber(L, 5));
  y0 = lua_tointeger(L, 2) - 1;
  x0 = lua_tointeger(L, 3) - 1;
  y1 = lua_tointeger(L, 4) - 1;
  x1 = lua_tointeger(L, 5) - 1;
  bresenham_line(screen->screen, x0, y0, x1, y1,
      screen->colors.white);
  return 0;
}

/* TODO */
static int screen_px_print(lua_State *L) {
  Vec2i pos;
  Screen *screen;
  int args_count = lua_gettop(L);
  assert(args_count == 4);
  assert(lua_isnumber(L, 2)
      && lua_isnumber(L, 3)
      && lua_isstring(L, 4));
  pos.y = lua_tointeger(L, 2) - 1;
  pos.x = lua_tointeger(L, 3) - 1;
  screen = check_screen(L, 1);
  render_text(screen->screen, &screen->font,
      lua_tostring(L, 4), pos);
  return 0;
}

static int compare_mem(void *data1, void *data2, int size) {
  int result = memcmp(data1, data2, size);
  return result == 0;
}

static int screen_compare(lua_State *L) {
  Screen *screen;
  SDL_Surface *real;
  SDL_Surface *tmp;
  SDL_Surface *expected;
  int is_equal;
  int size;
  int bpp_real;
  int bpp_expected;
  screen = check_screen(L, 1);
  real = screen->screen;
  bpp_real = real->format->BytesPerPixel;
  tmp = IMG_Load(lua_tostring(L, 2));
  /* convert to screen format */
  expected = SDL_DisplayFormat(tmp);
  bpp_expected = expected->format->BytesPerPixel;
  SDL_FreeSurface(tmp);
  bpp_real = expected->format->BytesPerPixel;
  assert(expected);
  assert(bpp_real == bpp_expected);
  assert(real->w == expected->w);
  assert(real->h == expected->h);
  size = expected->w * expected->h * bpp_expected;
  is_equal = compare_mem(real->pixels, expected->pixels, size);
  SDL_FreeSurface(expected);
  lua_pushboolean(L, is_equal);
  return 1;
}

static const luaL_Reg screen_functions[] = {
  {"new", screen_new},
  {"init", screen_init},
  {"close", screen_close},
  {"move", screen_move},
  {"printf", screen_printf},
  {"clear", screen_clear},
  {"refresh", screen_refresh},
  {"get_char", screen_get_char},
  {"delay", screen_delay},
  {"line", screen_line},
  {"px_print", screen_px_print},
  {"compare", screen_compare},
#if 0
  {"coords_to_tile", screen_corrds_to_pixel},
  {"coords_to_pixel", screen_coords_to_tile},
#endif
  {NULL, NULL}
};

static int screen_gc(lua_State *L) {
#if 0
  printf("bye, bye, screen = %p\n",
      (void*)to_screen(L, 1));
#endif
  return 0;
}

static const luaL_Reg screen_meta[] = {
  {"__gc", screen_gc},
  {NULL, NULL}
};

LUALIB_API int luaopen_screen(lua_State *L) {
  /* new module */
  luaL_newlib(L, screen_functions);
  /* create metatable for file handles */
  luaL_newmetatable(L, SCREEN);
  /* push metatable */
  lua_pushvalue(L, -1);
  /* metatable.__index = metatable */
  lua_setfield(L, -2, "__index");
  /* add file methods to new metatable */
  luaL_setfuncs(L, screen_functions, 0);
  /* . . . */
  luaL_setfuncs(L, screen_meta, 0);
  /* pop new metatable */
  lua_pop(L, 1);
  return 1;
}
