
let state = LibMerlin.start "ocamlmerlin" []
let fname = LibAcme.gfile ()
let () = match LibMerlin.load_project ~state fname with
	| None -> exit 2
	| Some _ -> ()
let () = match LibMerlin.reset ~state fname with
	| None -> exit 2
	| Some () -> ()
let content = LibAcme.get_content ()
let () = match LibMerlin.tell_string ~state content with
	| None -> exit 2
	| Some _ -> ()

let addr = LibAcme.get_addr (Acme.Win.current ())
let ident = LibAcme.ident_under_point content addr
let position = LibAcme.from_offset content addr

let () =
	match LibMerlin.locate ~state ident position with
	| None ->
		LibAcme.erase_and_put []
	| Some (fname, (c, l)) ->
		LibAcme.erase_and_put [Printf.sprintf "%s:%d:%d\n" fname c l]

