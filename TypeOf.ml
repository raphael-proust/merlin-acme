
let state = LibMerlin.start "ocamlmerlin" []
let () = match LibMerlin.reset ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let content = LibAcme.get_content ()

let () = match LibMerlin.tell_string ~state content with
	| None -> exit 2
	| Some _ -> ()

let () =
	let wid = LibAcme.new_window () in
	let fname = LibAcme.gfile () in
	let a = LibAcme.get_addr (LibAcme.gwid ()) in
	let (x,y) as position = LibAcme.from_offset content a in
	let types = LibMerlin.type_enclosing ~state ("", 0) position in
	match types with
	| None -> ()
	| Some l ->
		List.iter
			(fun (t, ((sl, sc), (el, ec))) ->
				if el = sl then
					LibAcme.put wid
						(Printf.sprintf "%s:%d:%d-%d: %s\n" fname sl sc ec t )
				else
					() (*TODO: better plumbing rules*)
			)
			l;
		LibAcme.ctl wid LibAcme.Clean;
		LibAcme.ctl wid LibAcme.Show
