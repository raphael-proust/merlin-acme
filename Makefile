
BINDIR=$(shell opam config var bin)
SOURCES=Cplt.ml TypeOf.ml Locate.ml Errors.ml
LIBS=LibMerlin.cmo LibAcme.cmo
REQUIRES=unix,str,batteries,yojson,o9p,acme

all: $(LIBS) $(SOURCES:.ml=.cmo)
	ocamlfind ocamlc -package $(REQUIRES) -linkpkg -o Cplt $(LIBS) Cplt.cmo
	ocamlfind ocamlc -package $(REQUIRES) -linkpkg -o TypeOf $(LIBS) TypeOf.cmo
	ocamlfind ocamlc -package $(REQUIRES) -linkpkg -o Locate $(LIBS) Locate.cmo
	ocamlfind ocamlc -package $(REQUIRES) -linkpkg -o Errors $(LIBS) Errors.cmo

%.cmo: %.ml
	ocamlfind ocamlc -package $(REQUIRES) -c -o $@ $<

install: all
	install -d -m 755 $(BINDIR)
	install Cplt $(BINDIR)
	install TypeOf $(BINDIR)
	install Locate $(BINDIR)
	install Errors $(BINDIR)

uninstall:
	rm -f $(BINDIR)/Cplt
	rm -f $(BINDIR)/TypeOf
	rm -f $(BINDIR)/Locate
	rm -f $(BINDIR)/Errors

clean:
	rm -f *.cm? *.o *.a

purge: clean
	rm -f $(SOURCES:.ml=)

