CC = i686-w64-mingw32-gcc
STRIP = i686-w64-mingw32-strip
DLLTOOL = i686-w64-mingw32-dlltool
KPACK = kpack

LIBDIR=$(abspath ../lib)

CFLAGS = -Isrc/include -Isrc -D_BUILD_LIBC -nostdinc -c -Os \
         -fno-builtin -fno-ident -ffreestanding -fno-leading-underscore \
         -fno-stack-check -fno-stack-protector -mno-stack-arg-probe -fno-exceptions \
         -fno-asynchronous-unwind-tables -fno-delete-null-pointer-checks

all: $(LIBDIR)/libc.obj.a $(LIBDIR)/libc.obj $(LIBDIR)/crtdll.o 

$(LIBDIR)/libc.obj.a: libc.def
	$(DLLTOOL) --no-leading-underscore -d $< -l $@

$(LIBDIR)/libc.obj: src/libc.c
	bash export-gen.sh
	$(CC) $(CFLAGS) $< -o $@
	$(STRIP) --strip-unneeded $@
	$(KPACK) $@

$(LIBDIR)/crtdll.o: src/crtdll.c
	$(CC) $(CFLAGS) $< -o $@


.PHONY: clean
clean:
	rm -rf $(LIBDIR)/libc.obj.a $(LIBDIR)/libc.obj $(LIBDIR)/crtdll.o src/export.c
