
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


#dependencies

Cplt.cmo : LibMerlin.cmo LibAcme.cmo
Cplt.cmx : LibMerlin.cmx LibAcme.cmx
Errors.cmo : LibMerlin.cmo LibAcme.cmo
Errors.cmx : LibMerlin.cmx LibAcme.cmx
LibAcme.cmo : o9pc.cmo fcall.cmo
LibAcme.cmx : o9pc.cmx fcall.cmx
LibMerlin.cmo :
LibMerlin.cmx :
Locate.cmo : LibMerlin.cmo LibAcme.cmo
Locate.cmx : LibMerlin.cmx LibAcme.cmx
TypeOf.cmo : LibMerlin.cmo LibAcme.cmo
TypeOf.cmx : LibMerlin.cmx LibAcme.cmx
fcall.cmo :
fcall.cmx :
o9pc.cmo : fcall.cmo
o9pc.cmx : fcall.cmx
