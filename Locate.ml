
let state = LibMerlin.start "ocamlmerlin" []

let () = match LibMerlin.load_project ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some _ -> ()

let () = match LibMerlin.reset ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let () = match LibMerlin.tell_string ~state (LibAcme.get_content ()) with
	| None -> exit 2
	| Some _ -> ()

let () =
	let wid = LibAcme.new_window () in
	let identifier = "tell_string" in (*TODO*)
	let position = (6,26) in (*TODO*)
	let place = LibMerlin.locate ~state identifier position in
	match place with
		| None -> ()
		| Some (fname, (c, l)) ->
			LibAcme.put wid (Printf.sprintf "%s:%d:%d\n" fname c l);
			LibAcme.ctl wid LibAcme.Clean;
			LibAcme.ctl wid LibAcme.Show

