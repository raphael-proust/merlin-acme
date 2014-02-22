
let state = LibMerlin.start "ocamlmerlin" []
let () = match LibMerlin.load_project ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some _ -> ()
let () = match LibMerlin.reset ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let content = LibAcme.get_content ()

let () = match LibMerlin.tell_string ~state content with
	| None -> exit 2
	| Some _ -> ()

let () =
	let a = LibAcme.get_addr (LibAcme.gwid ()) in
	let ident = LibAcme.ident_under_point content a in
	let position = LibAcme.from_offset content a in
	let place = LibMerlin.locate ~state ident position in
	match place with
	| None -> ()
	| Some (fname, (c, l)) ->
		LibAcme.erase_and_put [Printf.sprintf "%s:%d:%d\n" fname c l]

