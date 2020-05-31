OPENLIBM_HOME=$(abspath .)
include ./Make.inc

SUBDIRS = src $(ARCH) bsdsrc
# Add ld80 directory on x86 and x64
ifneq ($(filter $(ARCH),i387 amd64),)
SUBDIRS += ld80
else
ifneq ($(filter $(ARCH),aarch64),)
SUBDIRS += ld128
else
endif
endif

define INC_template
TEST=test
override CUR_SRCS = $(1)_SRCS
include $(1)/Make.files
SRCS += $$(addprefix $(1)/,$$($(1)_SRCS))
endef

DIR=test

$(foreach dir,$(SUBDIRS),$(eval $(call INC_template,$(dir))))

DUPLICATE_NAMES = $(filter $(patsubst %.S,%,$($(ARCH)_SRCS)),$(patsubst %.c,%,$(src_SRCS)))
DUPLICATE_SRCS = $(addsuffix .c,$(DUPLICATE_NAMES))

OBJS =  $(patsubst %.f,%.f.o,\
	$(patsubst %.S,%.S.o,\
	$(patsubst %.c,%.c.o,$(filter-out $(addprefix src/,$(DUPLICATE_SRCS)),$(SRCS)))))
ifneq ($(OBJROOT),)
OBJS := $(addprefix $(OBJROOT)/,$(OBJS))
endif

OUTPUT_NAME = libopenlibm.$(OLM_MAJOR_MINOR_SHLIB_EXT)

# If we're on windows, don't do versioned shared libraries. Also, generate an import library
# for the DLL. If we're on OSX, put the version number before the .dylib.  Otherwise,
# put it after.
ifeq ($(OS), WINNT)
OLM_MAJOR_MINOR_SHLIB_EXT := $(SHLIB_EXT)
LDFLAGS_add += -Wl,--out-implib,libopenlibm.$(OLM_MAJOR_MINOR_SHLIB_EXT).a
else
ifeq ($(OS), Darwin)
OLM_MAJOR_MINOR_SHLIB_EXT := $(SOMAJOR).$(SOMINOR).$(SHLIB_EXT)
OLM_MAJOR_SHLIB_EXT := $(SOMAJOR).$(SHLIB_EXT)
LDFLAGS_add += -compatibility_version 1.0.0
LDFLAGS_add += -current_version $(SOMAJOR).$(SOMINOR).$(VERSION)
CFLAGS_add += -D__PUREDARWIN__=1
OUTPUT_NAME = libsystem_m.dylib
else
OLM_MAJOR_MINOR_SHLIB_EXT := $(SHLIB_EXT).$(SOMAJOR).$(SOMINOR)
OLM_MAJOR_SHLIB_EXT := $(SHLIB_EXT).$(SOMAJOR)
endif
endif

ifneq ($(OBJROOT),)
OUTPUT_NAME := $(OBJROOT)/$(OUTPUT_NAME)
endif

.PHONY: all check test clean distclean \
	install install-static install-shared install-pkgconfig install-headers

all: $(OUTPUT_NAME)

check test: test/test-double test/test-float
	test/test-double
	test/test-float

$(OUTPUT_NAME): $(OBJS)
	$(CC) -shared $(OBJS) $(LDFLAGS) $(LDFLAGS_add) -Wl,$(SONAME_FLAG),$(SONAME) -o $@

test/test-double: libopenlibm.$(OLM_MAJOR_MINOR_SHLIB_EXT)
	$(MAKE) -C test test-double

test/test-float: libopenlibm.$(OLM_MAJOR_MINOR_SHLIB_EXT)
	$(MAKE) -C test test-float

clean:
	rm -f $(OBJS)
	rm -f aarch64/*.o amd64/*.o arm/*.o bsdsrc/*.o i387/*.o ld80/*.o ld128/*.o src/*.o powerpc/*.o
	rm -f libopenlibm.a libopenlibm.*$(SHLIB_EXT)*
	$(MAKE) -C test clean

openlibm.pc: openlibm.pc.in Make.inc Makefile
	echo "prefix=${prefix}" > openlibm.pc
	echo "version=${VERSION}" >> openlibm.pc
	cat openlibm.pc.in >> openlibm.pc

install-shared: $(OUTPUT_NAME)
	mkdir -p $(DESTDIR)$(shlibdir)
	cp -RpP -f $(OUTPUT_NAME) $(DESTDIR)$(shlibdir)/

install: install-shared
