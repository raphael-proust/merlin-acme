open Acme (*Gives Addr, Ctl, and Win*)

let reuse = ()

(* Global env *)
let ns = Sys.getenv "NAMESPACE"
let user = Sys.getenv "USER"

(* window specific env *)
let gfile () = Sys.getenv "%"

let get_conn () = O9pc.connect (Printf.sprintf "%s/acme" ns)

let get_io conn perm fname = O9pc.(
	let fid = attach conn ~user  "" in
	let fid = walk conn fid ~reuse fname in
	let io = fopen conn fid perm in
	(fid, io)
)
let get_fullio perm fname = O9pc.(
	let conn = get_conn () in
	let (fid, io) = get_io conn perm fname in
	(conn, fid, io)
)

let get_window ?conn name = O9pc.(
	let idx = Idx.get ?conn () in
	let i = List.find (fun t -> Idx.filename t = name) idx in
	i.Idx.win
)

let new_window name = O9pc.(
	let conn = get_conn () in
	let (fid, io) = get_io conn oWRITE Win.(path new_ Ctl) in
	let (_:int32) = write conn fid io Ctl.(p (Name name)) in
	clunk conn fid;
	get_window ~conn name
)

let merlin_winid =
	try
		try
			get_window "+Merlin"
		with Not_found ->
			new_window "+Merlin"
	with e -> Printf.eprintf "%s\n%!" (Printexc.to_string e); raise e


let erase_and_put ms =
	let (addrconn, addrfid, addrio) = get_fullio O9pc.oWRITE Win.(path merlin_winid Addr) in
	let (dataconn, datafid, dataio) = get_fullio O9pc.oWRITE Win.(path merlin_winid Data) in
	let (ctlconn, ctlfid, ctlio) = get_fullio O9pc.oWRITE Win.(path merlin_winid Ctl) in
	let (_:int32) = O9pc.write addrconn addrfid addrio Addr.(p (Comma (Null, Null))) in
	let (_:int32) = O9pc.write dataconn datafid dataio "" in
	List.iter (fun m ->
			O9pc.write dataconn datafid dataio m
			|> (ignore: int32 -> unit)
		)
		ms;
	let (_:int32) = O9pc.write addrconn addrfid addrio Addr.(p Zero) in
	let (_:int32) = O9pc.write ctlconn ctlfid ctlio Ctl.(ps [Clean; DotEqAddr; Show]) in
	O9pc.clunk addrconn addrfid;
	O9pc.clunk dataconn datafid;
	O9pc.clunk ctlconn ctlfid;
	()

let get_content () =
	let conn = get_conn () in
	let wid = Win.current () in
	let b = Buffer.create 1024 in
	let (fid, io) = get_io conn O9pc.oREAD Win.(path wid Body) in
	let rec fill offset =
		let r = O9pc.read conn fid io ~offset:(Int64.of_int offset) 1024l in
		if r = "" then
			()
		else (
			Buffer.add_string b r;
			fill (offset + String.length r)
		)
	in
	fill 0;
	O9pc.clunk conn fid;
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
	let root_addr = attach conn_addr ~user  "" in
	let addr_fid = walk conn_addr root_addr ~reuse Win.(path winid Addr) in
	let addr_iounit = fopen conn_addr addr_fid oREAD in

	(* open ctl *)
	let conn_ctl = get_conn () in
	let root_ctl = attach conn_ctl ~user  "" in
	let ctl_fid = walk conn_ctl root_ctl ~reuse Win.(path winid Ctl) in
	let ctl_iounit = fopen conn_ctl ctl_fid oWRITE in

	(* write to ctl and read from addr *)
	let (_:int32) = write conn_ctl ctl_fid ctl_iounit Ctl.(p AddrEqDot) in
	let s = read conn_addr addr_fid addr_iounit 1024l in
	
	(* clean up *)
	clunk conn_addr addr_fid;
	clunk conn_ctl ctl_fid;
	
	(* scan *)
	Scanf.sscanf s " %d" (fun x -> x)
)