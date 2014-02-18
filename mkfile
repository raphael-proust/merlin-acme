
TRGTS=Cplt.merlin TypeOf.merlin
LIBS=fcall.cmo o9pc.cmo Lib.cmo merlin.cmo

all:V: $TRGTS

%.merlin: %.ml $LIBS
	ocamlfind ocamlc -package unix,str,batteries,yojson -linkpkg -o $target $LIBS $stem.ml

%.cmo: %.ml
	ocamlfind ocamlc -package unix,str,batteries,yojson -c -o $target $prereq

clean:V:
	rm -f $TRGTS
	rm -f *.cm? *.o *.a
