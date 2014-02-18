

(*TODO: unhack*)
let addr winid =
	let (ic, oc) = Unix.open_process (Printf.sprintf "9p rdwr acme/%s/addr" winid) in
	let (_: string) = input_line ic in
	let occtl = Unix.open_process_out (Printf.sprintf "9p write acme/%s/ctl" winid) in
	let () = output_string occtl "addr=dot\n" in
	let () = flush occtl in
	let () = Unix.sleep 1 in
	let () = output_string oc "\n" in
	let () = flush oc in
	let s = input_line ic in
	let () = close_out occtl in
	let () = close_out oc; close_in ic in
	Printf.printf "%s\n%!" s;
	Scanf.sscanf s " %d" (fun x -> x)