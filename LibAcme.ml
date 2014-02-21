
type addr (*TODO*) = string
type command (*???*)
type dirname = string

type ctl_msg =
	| AddrEqDot
	| Clean
	| Dirty
	| Cleartag
	| Del
	| Delete
	| DotEqAddr
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
	| DotEqAddr -> "dot=addr"
	| Dump cmd -> failwith "TODO"
	| Dumpdir dirname -> "dumpdir " ^ dirname
	| Get -> "get"
	| Limit addr -> failwith "TODO"
	| Mark -> "mark"
	| Name name -> "name " ^ name
	| Nomark -> "nomark"
	| Put -> "put"
	| Show -> "show"

let env k = Sys.getenv k

(* Global env *)
let ns = env "NAMESPACE"
let user = env "USER"

(* window specific env *)
let gwid () = env "winid"
let gfile () = env "%"

let get_conn () = O9pc.connect (Printf.sprintf "%s/acme" ns)

let get_fullio perm fname = O9pc.(
	let conn = get_conn () in
	let fid = attach conn user "" in
	let fid = walk conn fid true fname in
	let io = fopen conn fid perm in
	(conn, fid, io)
)
let get_io conn perm fname = O9pc.(
	let fid = attach conn user "" in
	let fid = walk conn fid true fname in
	let io = fopen conn fid perm in
	(fid, io)
)

let new_window () = O9pc.(
	let (conn, fid, io) = get_fullio oREAD "" in
	let data = read conn fid io 0L 4096l in
	let files = List.map (fun x -> x.Fcall.name) (unpack_files data) in
	clunk conn fid;
	let (fid, io) = get_io conn oWRITE "new/body" in
	let (_:int32) = write conn fid io 0L 0l "" in
	clunk conn fid;
	let (fid, io) = get_io conn oREAD "" in
	let data = read conn fid io 0L 4096l in
	let newfiles = List.map (fun x -> x.Fcall.name) (unpack_files data) in
	clunk conn fid;
	let filename (*racy*) = List.find (fun f -> not (List.exists (fun ff -> f = ff) files)) newfiles in
	filename
)

let merlin_winid =
	try
		try
			let i = open_in_gen [Open_rdonly] 0o600 (Printf.sprintf "%s/mwinid" ns) in
			let s = input_line i in
			close_in i;
			(* test wether the file exists *)
			let conn = get_conn () in
			let fid = O9pc.attach conn user "" in
			let fid = O9pc.walk conn fid true s in
			O9pc.clunk conn fid;
			s
		with e -> begin
			Printf.eprintf "%s\n%!" (Printexc.to_string e);
			let mw = new_window () in
			let (ctlconn, ctlfid, ctlio) = get_fullio O9pc.oWRITE (Printf.sprintf "%s/ctl" mw) in
			let (_:int32) = O9pc.write ctlconn ctlfid ctlio 0L 13l "name +Merlin\n" in
			let o = open_out_gen [Open_wronly; Open_creat; Open_trunc] 0o600 (Printf.sprintf "%s/mwinid" ns) in
			output_string o mw;
			flush o;
			close_out o;
			mw
		end
	with e -> Printf.eprintf "%s\n%!" (Printexc.to_string e); raise e


let erase_and_put ms =
	let (addrconn, addrfid, addrio) = get_fullio O9pc.oWRITE (Printf.sprintf "%s/addr" merlin_winid) in
	let (dataconn, datafid, dataio) = get_fullio O9pc.oWRITE (Printf.sprintf "%s/data" merlin_winid) in
	let (ctlconn, ctlfid, ctlio) = get_fullio O9pc.oWRITE (Printf.sprintf "%s/ctl" merlin_winid) in
	let (_:int32) = O9pc.write addrconn addrfid addrio 0L 1l "," in
	let (_:int32) = O9pc.write dataconn datafid dataio 0L 0l "" in
	List.iter (fun m ->
			O9pc.write dataconn datafid dataio 0L (Int32.of_int (String.length m)) m
			|> (ignore: int32 -> unit)
		)
		ms;
	let (_:int32) = O9pc.write addrconn addrfid addrio 0L 1l "0" in
	let (_:int32) = O9pc.write ctlconn ctlfid ctlio 0L 20l "clean\ndot=addr\nshow\n" in
	O9pc.clunk addrconn addrfid;
	O9pc.clunk dataconn datafid;
	O9pc.clunk ctlconn ctlfid;
	()

let get_content () =
	let conn = get_conn () in
	let wid = gwid () in
	let b = Buffer.create 1024 in
	let (fid, io) = get_io conn O9pc.oREAD (Printf.sprintf "%s/body" wid) in
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

let from_offset code offset = 
  let line = ref 1 and column = ref 0 in
  (try
    String.iteri (fun index c ->
      if c = '\n' then (column := 0; incr line)
      else (incr column);
      if index = offset then assert false) code;
  with _ -> ());
  (!line, !column)

let to_offset code (line, column) = 
  let ret = ref 0 in
  let rline = ref 1 and rcolumn = ref 0 in
  (try
    String.iteri (fun index c ->
      if c = '\n' then (incr rline; rcolumn := 0)
      else 
        (incr rcolumn;
         if !rcolumn = column && !rline = line then
           (ret := index; assert false))) code
  with _ -> ());
  !ret

let bounds_ident code offset = 
  let is_ident_char = function
    | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '\'' | '_' | '.' -> true
    | _ -> false
  in
  if not (is_ident_char code.[offset]) then (offset, offset)
  else
    let beginning = ref offset and stop = ref offset in
    while !beginning >= 0 && is_ident_char (code.[!beginning]) do decr beginning done;
    while !stop < String.length code && is_ident_char (code.[!stop]) do incr stop done;
    incr beginning;
    decr stop;
    (!beginning, !stop)

  
let ident_under_point code offset = 
  let (start, stop) = bounds_ident code offset in
  String.sub code start (stop - start+1)

(*TODO: unhack*)
let get_addr winid = O9pc.(
	(* open addr *)
	let conn_addr = get_conn () in
	let root_addr = attach conn_addr user "" in
	let addr_fid = walk conn_addr root_addr true (Printf.sprintf "%s/addr" winid) in
	let addr_iounit = fopen conn_addr addr_fid oREAD in

	(* open ctl *)
	let conn_ctl = get_conn () in
	let root_ctl = attach conn_ctl user "" in
	let ctl_fid = walk conn_ctl root_ctl true (Printf.sprintf "%s/ctl" winid) in
	let ctl_iounit = fopen conn_ctl ctl_fid oWRITE in

	(* write to ctl and read from addr *)
	let (_:int32) = write conn_ctl ctl_fid ctl_iounit 0L 9l "addr=dot\n" in
	let s = read conn_addr addr_fid addr_iounit 0L 1024l in
	
	(* clean up *)
	clunk conn_addr addr_fid;
	clunk conn_ctl ctl_fid;
	
	(* scan *)
	Scanf.sscanf s " %d" (fun x -> x)
)