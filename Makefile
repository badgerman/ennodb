PREFIX = /opt
CFLAGS = -g -Wall -Werror -Wextra -Icritbit -std=c99 -Wconversion
PROGRAMS = ennodb
TESTS = tests
WEBSITE = /var/www/html

ifeq "$(CC)" "clang"
CFLAGS += -Weverything -Wno-padded 
endif

# http://www.thinkplexx.com/learn/howto/build-chain/make-based/prevent-gnu-make-from-always-removing-files-it-says-things-like-rm-or-removing-intermediate-files
.SECONDARY: prefix.o

all: $(PROGRAMS) $(TESTS)

test: $(TESTS)
	@./tests

%.o: %.c %.h
	$(CC) $(CFLAGS) -o $@ -c $< $(INCLUDES)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $< $(INCLUDES)

critbit/CuTest.o: critbit/CuTest.c
	$(CC) $(CFLAGS) -Wno-format-nonliteral -o $@ -c $< $(INCLUDES)

critbit/critbit.o: critbit/critbit.c
	$(CC) $(CFLAGS) -Wno-sign-conversion -o $@ -c $< $(INCLUDES)

cgiapp.a: cgiapp.o critbit/critbit.o
	$(AR) -q $@ $^

ennodb: ennodb.o nosql.o cgiapp.a
	$(CC) $(CFLAGS) -o $@ $^ -lfcgi $(LDFLAGS)

tests: tests.o nosql.o critbit/test_critbit.o critbit/CuTest.o critbit/critbit.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f *~ *.a *.o critbit/*.o $(PROGRAMS) $(TESTS)

install: $(PROGRAMS)
	sudo mkdir -p $(PREFIX)/bin
	install html/*.* $(WEBSITE)
	sudo install $(PROGRAMS) $(PREFIX)/bin
	sudo install etc/init.d/* /etc/init.d/
	sudo install etc/nginx/* /etc/nginx/