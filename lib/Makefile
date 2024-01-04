LIBS ?= md5.so fs.so network.so
DEFS ?= 
EXTRA_CFLAGS ?= -I. -Wall -Werror -fpic
EXTRA_LDFLAGS ?= -shared
CFLAGS += $(DEFS) $(EXTRA_CFLAGS)
LDFLAGS += $(EXTRA_LDFLAGS)

all: $(LIBS)

MD5_SRCS = md5.c
FS_SRCS = fs.c
NETWORK_SRCS = network.c

md5.so:
	$(CC) $(MD5_SRCS) $(CFLAGS) $(LDFLAGS) -o $@

fs.so:
	$(CC) $(FS_SRCS) $(CFLAGS) $(LDFLAGS) -o $@

network.so:
	$(CC) $(NETWORK_SRCS) $(CFLAGS) $(LDFLAGS) -o $@


clean:
	rm -rf *.o *.so
