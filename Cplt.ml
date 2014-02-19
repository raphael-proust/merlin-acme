
let state = Merlin.start "/home/bnwr/.opam/system/bin/ocamlmerlin" []

let () = match Merlin.load_project ~state (Lib.gfile ()) with
	| None -> exit 2
	| Some _ -> ()

let () = match Merlin.reset ~state (Lib.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let content = Lib.get_content ()

let () = match Merlin.tell_string ~state content with
	| None -> exit 2
	| Some _ -> ()


let () =
	let a = Lib.get_addr (Lib.gwid ()) in
	let ident = Lib.ident_under_point content a in
	let position = Lib.from_offset content a in
	let cplts = Merlin.complete ~state ident position in
	match cplts with
		| None | Some [] -> ()
		| Some (_::_ as l) ->
			let wid = Lib.new_window () in
			List.iter (fun {Merlin.kind; descr; name;} ->
					Lib.put wid (Printf.sprintf "%s\t(%s)\n\t%s\n" name kind descr)
				)
				l;
				Lib.ctl wid Lib.Clean;
				Lib.ctl wid Lib.Show
