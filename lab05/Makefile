CFLAGS = -std=c99 -Wall -Wextra
LDFLAGS = -lm

.PHONY: all clean

all: lab5a lab5b

lab5a: lab5a.c
	gcc $(CFLAGS) lab5a.c -o lab5a $(LDFLAGS)

lab5b: lab5b.c
	gcc $(CFLAGS) lab5b.c -o lab5b

clean:
	rm -f lab5a lab5b