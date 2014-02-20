
TRGTS=M/Cplt M/TypeOf M/Locate M/Errors
LIBS=fcall.cmo o9pc.cmo LibAcme.cmo LibMerlin.cmo

all:V: $TRGTS

M/%: %.ml $LIBS
	ocamlfind ocamlc -package unix,str,batteries,yojson -linkpkg -o $target $LIBS $stem.ml

%.cmo: %.ml
	ocamlfind ocamlc -package unix,str,batteries,yojson -c -o $target $prereq

clean:V:
	rm -f *.cm? *.o *.a

purge:V: clean
	rm -f $TRGTS
