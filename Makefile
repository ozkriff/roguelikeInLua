lua_path = /usr/include/lua5.2
# lua_path = /home/ozkriff/code/marauder/lua5.2/src
# CC = tcc
CC = gcc
CFLAGS = -g
CFLAGS += -I$(lua_path)
CFLAGS += -fPIC
CFLAGS += -std=c89 -Wall -Wextra --pedantic
all: screen.so
screen.so: screen.o
	$(CC) -o screen.so -shared -g screen.o -lSDL -lSDL_image
clean:
	rm -f screen.so screen.o
