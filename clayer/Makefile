DLLTOOL = i686-w64-mingw32-dlltool

LIBDIR=$(abspath ../lib)

all: $(LIBDIR)/libconsole.obj.a

$(LIBDIR)/libconsole.obj.a: console.def
	$(DLLTOOL) --no-leading-underscore -k -d $< -l $@

.PHONY: clean
clean:
	rm -rf $(LIBDIR)/libconsole.obj.a
