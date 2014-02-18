
let env k = Sys.getenv k

(* Global env *)
let ns = env "NAMESPACE"
let user = env "USER"

(* window specific env *)
let gwid () = int_of_string (env "winid")
let gfile () = env "%"

(* global connection to the fs interface *)
let conn = O9pc.connect (Printf.sprintf "%s/acme" ns)

let new_window () = O9pc.(
	let rootfid = attach conn user "" in
	let root_iounit = fopen conn rootfid oREAD in
	let data = read conn rootfid root_iounit 0L 4096l in
	let files = List.map (fun x -> x.Fcall.name) (unpack_files data) in
	clunk conn rootfid;
	let rootfid = attach conn user "" in
	let (_:int32) = fwrite conn rootfid "new/body" 0L 0l "" in
	let root_iounit = fopen conn rootfid oREAD in
	let data = read conn rootfid root_iounit 0L 4096l in
	let newfiles = List.map (fun x -> x.Fcall.name) (unpack_files data) in
	clunk conn rootfid;
	let filename (*racy*) = List.find (fun f -> not (List.exists (fun ff -> f = ff) files)) newfiles in
	filename
)


let put winid s = O9pc.(
	let root = attach conn user "" in
	let win_fid = walk conn root false (Printf.sprintf "%s/body" winid) in
	let win_iounit = fopen conn win_fid oWRITE in
	let (_:int32) = write conn win_fid win_iounit 0L (Int32.of_int (String.length s)) s in
	clunk conn win_fid
)

type addr (*TODO*)
type command (*???*)
type dirname = string

type ctl_msg =
	| AddrEqDot
	| Clean
	| Dirty
	| Cleartag
	| Del
	| Delete
	| DotEqAddr of addr
	| Dump of command
	| Dumpdir of dirname
	| Get
	| Limit of addr
	| Mark
	| Name of string
	| Nomark
	| Put
	| Show

let string_of_ctl_msg = function
	| AddrEqDot -> "addr=dot"
	| Clean -> "clean"
	| Dirty -> "dirty"
	| Cleartag -> "cleartag"
	| Del -> "del"
	| Delete -> "delete"
	| DotEqAddr addr -> failwith "TODO"
	| Dump cmd -> failwith "TODO"
	| Dumpdir dirname -> "dumpdir " ^ dirname
	| Get -> "get"
	| Limit addr -> failwith "TODO"
	| Mark -> "mark"
	| Name name -> "name " ^ name
	| Nomark -> "nomark"
	| Put -> "put"
	| Show -> "show"

let ctl winid ctlmsg = O9pc.(
	let root = attach conn user "" in
	let win_fid = walk conn root false (Printf.sprintf "%s/ctl" winid) in
	let win_iounit = fopen conn win_fid oWRITE in
	let s = string_of_ctl_msg ctlmsg ^ "\n" in
	let (_:int32) = write conn win_fid win_iounit 0L (Int32.of_int (String.length s)) s in
	clunk conn win_fid
)

let destroy_window winid = ctl winid Delete

let get_content () =
	let wid = gwid () in
	let b = Buffer.create 1024 in
	let rootfid = O9pc.attach conn user "" in
	let (fid, io) = O9pc.walk_open conn rootfid true (Printf.sprintf "%d/body" wid) O9pc.oREAD in
	let rec fill offset =
		let r = O9pc.read conn fid io (Int64.of_int offset) 1024l in
		if r = "" then
			()
		else (
			Buffer.add_string b r;
			fill (offset + String.length r)
		)
	in
	fill 0;
	O9pc.clunk conn fid;
(*	Printf.printf "%s\n%!" (Buffer.contents b); *)
	Buffer.contents b
