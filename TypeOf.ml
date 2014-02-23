
(* initialisation *)
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

let addr = LibAcme.get_addr (LibAcme.gwid ())
let position = LibAcme.from_offset content addr

let () =
	match LibMerlin.type_enclosing ~state ("", 0) position with
	| None ->
		LibAcme.erase_and_put []
	| Some l ->
		(*TODO: set dot to the range of the first result*)
		LibAcme.erase_and_put
			(List.map (fun (t, range) ->
				Printf.sprintf "%s: %s\n" (LibAcme.print_range fname content range) t
				)
				l)
