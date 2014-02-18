
let state = Merlin.start "/home/bnwr/.opam/system/bin/ocamlmerlin" []

let () = match Merlin.load_project ~state (Lib.gfile ()) with
	| None -> exit 2
	| Some _ -> ()

let () = match Merlin.reset ~state (Lib.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let () = match Merlin.tell_string ~state (Lib.get_content ()) with
	| None -> exit 2
	| Some _ -> ()

let () =
	let wid = Lib.new_window () in
	let identifier = "tell_string" in (*TODO*)
	let position = (6,26) in (*TODO*)
	let place = Merlin.locate ~state identifier position in
	match place with
		| None -> ()
		| Some (fname, (c, l)) ->
			Lib.put wid (Printf.sprintf "%s:%d:%d\n" fname c l);
			Lib.ctl wid Lib.Clean

