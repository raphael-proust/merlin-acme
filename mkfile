
TRGTS=Cplt.merlin TypeOf.merlin Locate.merlin Errors.merlin
LIBS=fcall.cmo o9pc.cmo Lib.cmo merlin.cmo addr.cmo

all:V: $TRGTS

%.merlin: %.cmo $LIBS
	ocamlfind ocamlc -package unix,str,batteries,yojson -linkpkg -o $target $LIBS $stem.cmo

%.cmo: %.ml
	ocamlfind ocamlc -package unix,str,batteries,yojson -c -o $target $prereq

clean:V:
	rm -f $TRGTS
	rm -f *.cm? *.o *.a
