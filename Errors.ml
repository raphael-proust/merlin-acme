
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

let () =
	match LibMerlin.errors ~state with
	| None | Some [] ->
		LibAcme.erase_and_put []
	| Some (_::_ as l) ->
		LibAcme.erase_and_put
			(List.map (fun (t, range) ->
				Printf.sprintf "%s: %s\n" (LibAcme.print_range fname content range) t
			)
			l)

