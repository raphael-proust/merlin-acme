
let mw =
	let wid = LibAcme.new_window () in
	LibAcme.(ctl wid (Name "+Merlin"));
	wid

let (ctlconn, ctlfid, ctlio) = O9pc.(
	let conn = connect (Printf.sprintf "%s/acme" LibAcme.ns) in
	let fid = attach conn LibAcme.user "" in
	let fid = walk conn fid true (Printf.sprintf "%s/ctl" mw) in
	let io = fopen conn fid oWRITE in
	(conn, fid, io)
)

let ctl m =
	let s = LibAcme.string_of_ctl_msg m ^ "\n" in
	O9pc.write ctlconn ctlfid ctlio 0L (Int32.of_int (String.length s)) s
	|> (ignore: int32 -> unit)
let ctls ms =
	let s = String.concat "\n" (List.map LibAcme.string_of_ctl_msg ms) ^ "\n" in
	O9pc.write ctlconn ctlfid ctlio 0L (Int32.of_int (String.length s)) s
	|> (ignore: int32 -> unit)

let (addrconn, addrfid, addrio) = O9pc.(
	let conn = connect (Printf.sprintf "%s/acme" LibAcme.ns) in
	let fid = attach conn LibAcme.user "" in
	let fid = walk conn fid true (Printf.sprintf "%s/addr" mw) in
	let io = fopen conn fid oWRITE in
	(conn, fid, io)
)

let addr a =
	O9pc.write addrconn addrfid addrio 0L (Int32.of_int (String.length a)) a
	|> (ignore: int32 -> unit)

let (bodyconn, bodyfid, bodyio) = O9pc.(
	let conn = connect (Printf.sprintf "%s/acme" LibAcme.ns) in
	let fid = attach conn LibAcme.user "" in
	let fid = walk conn fid true (Printf.sprintf "%s/body" mw) in
	let io = fopen conn fid oWRITE in
	(conn, fid, io)
)

let body m =
	O9pc.write bodyconn bodyfid bodyio 0L (Int32.of_int (String.length m)) m
	|> (ignore: int32 -> unit)

let bodys ms =
	List.iter (fun m ->
		O9pc.write bodyconn bodyfid bodyio 0L (Int32.of_int (String.length m)) m
		|> (ignore: int32 -> unit)
		)
		ms

let messages ms =
	addr ",";
	bodys ms

(* TODO:
- should we use the errors window?
- export wm as merlinwinid so that other tools can send messages to it
- conserve state:
	- merlin pipe
	- what buffer and to what offset has merlin been told the content of
*)
