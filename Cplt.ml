
let state = LibMerlin.start "ocamlmerlin" []

let () = match LibMerlin.reset ~state (LibAcme.gfile ()) with
	| None -> exit 2
	| Some () -> ()

let content = LibAcme.get_content ()

let () = match LibMerlin.tell_string ~state content with
	| None -> exit 2
	| Some _ -> ()


let get_mw () =
	try
		let i = open_in_gen [Open_rdonly] 0o600 (Printf.sprintf "%s/mwinid" LibAcme.ns) in
		let s = input_line i in
		close_in i;
		s
	with e -> Printf.eprintf "%s\n%!" (Printexc.to_string e); raise e

let () =
	let a = LibAcme.get_addr (LibAcme.gwid ()) in
	let ident = LibAcme.ident_under_point content a in
	let position = LibAcme.from_offset content a in
	let cplts = LibMerlin.complete ~state ident position in
	match cplts with
	| None | Some [] -> ()
	| Some (_::_ as l) ->
		LibAcme.erase_and_put
			(List.map (fun {LibMerlin.kind; descr; name;} ->
				Printf.sprintf "%s\t(%s)\n\t%s\n" name kind descr		
			)
			l)
