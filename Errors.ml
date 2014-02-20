
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
	let fname = LibAcme.gfile () in
	let errs = LibMerlin.errors ~state in
	match errs with
	| None | Some [] -> ()
	| Some (_::_ as l) ->
		LibAcme.erase_and_put
			(List.map (fun (text, ((sc, sl), (ec, el))) ->
				if sc = ec then
					Printf.sprintf "%s:%d:%d-%d: %s\n" fname sc sl el text
				else
					"" (*TODO*)
			)
			l)

