
let state = Merlin.start "ocamlmerlin" []

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
	let fname = Lib.gfile () in
	let errs = Merlin.errors ~state in
	match errs with
		| None | Some [] -> ()
		| Some (_::_ as l) ->
			let wid = Lib.new_window () in
			List.iter (fun (text, ((sc, sl), (ec, el))) ->
				if sc = ec then
					Lib.put wid (Printf.sprintf "%s:%d:%d-%d: %s\n" fname sc sl el text)
				else
					()
				)
				l;
				Lib.ctl wid Lib.Clean;
				Lib.ctl wid Lib.Show
