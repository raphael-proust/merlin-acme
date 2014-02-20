
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
	let cplts = LibMerlin.complete ~state ident position in
	match cplts with
		| None | Some [] -> ()
		| Some (_::_ as l) ->
			let wid = LibAcme.new_window () in
			List.iter (fun {LibMerlin.kind; descr; name;} ->
					LibAcme.put wid (Printf.sprintf "%s\t(%s)\n\t%s\n" name kind descr)
				)
				l;
				LibAcme.ctl wid LibAcme.Clean;
				LibAcme.ctl wid LibAcme.Show
