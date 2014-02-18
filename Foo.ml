
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
		(*get root attach, get the data and list the files*)
	let root = attach conn user "" in
	let root_iounit = fopen conn root oREAD in
	let data = read conn root root_iounit 0L 4096l in
	let files = List.map (fun x -> x.Fcall.name) (unpack_files data) in

		(*close the root attach because we can't "walk an open file"*)
	clunk conn root;
		(*get a new root attach and walk it*)
	let root = attach conn user "" in
	let mwin_fid = walk conn root false "new/body" in
	let mwin_iounit = fopen conn mwin_fid oWRITE in
		(*this makes a new window*)
	let (_:int32) = write conn mwin_fid mwin_iounit 0L 0l "" in
		(*list files again*)
	let root_iounit = fopen conn root oREAD in
	let data = read conn root root_iounit 0L 4096l in
	let newfiles = List.map (fun x -> x.Fcall.name) (unpack_files data) in
	clunk conn mwin_fid;
	clunk conn root;

		(*get the new file*)
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
let win_name = new_window ()

let () = put win_name "foo\nsplash"

