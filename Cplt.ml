
(*
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
*)
(*

let () =
	let a = Addr.addr (Printf.sprintf "%d" (Lib.gwid ())) in
	Printf.printf "ADDRESS: %d%!" a

let () =
	let ident = "Merlin.tell" in
	let position = (12,26) in
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
*)