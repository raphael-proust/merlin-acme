
TRGTS=M/Cplt M/TypeOf M/Locate M/Errors
LIBS=LibAcme.cmo LibMerlin.cmo
REQUIRES=unix,str,batteries,yojson,o9p,acme

all:V: $TRGTS

M/%: %.ml $LIBS
	ocamlfind ocamlc -package $REQUIRES -linkpkg -o $target $LIBS $stem.ml

%.cmo: %.ml
	ocamlfind ocamlc -package $REQUIRES -c -o $target $prereq

clean:V:
	rm -f *.cm? *.o *.a

purge:V: clean
	rm -f $TRGTS


#dependencies

Cplt.cmo : LibMerlin.cmo LibAcme.cmo
Cplt.cmx : LibMerlin.cmx LibAcme.cmx
Errors.cmo : LibMerlin.cmo LibAcme.cmo
Errors.cmx : LibMerlin.cmx LibAcme.cmx
LibAcme.cmo :
LibAcme.cmx :
LibMerlin.cmo :
LibMerlin.cmx :
Locate.cmo : LibMerlin.cmo LibAcme.cmo
Locate.cmx : LibMerlin.cmx LibAcme.cmx
TypeOf.cmo : LibMerlin.cmo LibAcme.cmo
TypeOf.cmx : LibMerlin.cmx LibAcme.cmx

