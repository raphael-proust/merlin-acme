
let buffer_content =
	let wid = Lib.gwid () in
	let b = Buffer.create 1024 in
	let rootfid = O9pc.attach Lib.conn Lib.user "" in
	let (fid, io) = O9pc.walk_open Lib.conn rootfid true (Printf.sprintf "%d/body" wid) O9pc.oREAD in
	let rec fill offset =
		let r = O9pc.read Lib.conn fid io (Int64.of_int offset) 1024l in
		if r = "" then
			()
		else (
			Buffer.add_string b r;
			fill (offset + String.length r)
		)
	in
	fill 0;
	O9pc.clunk Lib.conn fid;
(*	Printf.printf "%s\n%!" (Buffer.contents b); *)
	Buffer.contents b

let byte_offset =
	let wid = Lib.gwid () in
	let () = Lib.ctl (string_of_int wid) Lib.AddrEqDot in
	let rootfid = O9pc.attach Lib.conn Lib.user "" in
	let (ctlfid, ctlio) = O9pc.walk_open Lib.conn rootfid true (Printf.sprintf "%d/ctl" wid) O9pc.oREAD in
	let (_:int32) = O9pc.write Lib.conn ctlfid ctlio 0L 9l "addr=dot\n" in
	let (addrfid, addrio) = O9pc.walk_open Lib.conn rootfid true (Printf.sprintf "%d/addr" wid) O9pc.oREAD in
	let s = O9pc.read Lib.conn addrfid addrio 0L 1024l in
	(*TODO: manage the case when addr is #m,#n *)
	Printf.printf "%s\n%!" s;
	Printf.printf "%d\n%!" wid;
	O9pc.clunk Lib.conn addrfid;
	let addr = Scanf.sscanf s " %d" (fun x -> x) in
	Printf.printf "%d\n%!" addr;
	addr
