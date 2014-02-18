
let ns = Sys.getenv "NAMESPACE"
let wid = int_of_string (Sys.getenv "winid")
let file = Sys.getenv "%"
let user = Sys.getenv "USER"

let () = O9pc.(
		(*establish connection*)
	let conn = connect (Printf.sprintf "%s/acme" ns) in

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
	let (_:int32) = write conn mwin_fid mwin_iounit 0L 4l "foo\n" in
		(*this writes to the same window*)
	let (_:int32) = write conn mwin_fid mwin_iounit 0L 4l "bar\n" in
		(*list files again*)
	let root_iounit = fopen conn root oREAD in
	let data = read conn root root_iounit 0L 4096l in
	let newfiles = List.map (fun x -> x.Fcall.name) (unpack_files data) in

		(*get the new file*)
	let filename (*racy*) = List.find (fun f -> not (List.exists (fun ff -> f = ff) files)) newfiles in
	Printf.printf "%s\n%!" filename;

		(*close the root attach because we can't "walk an open file"*)
	clunk conn root;	
	let root = attach conn user "" in
	let mwin_fid = walk conn root false (Printf.sprintf "%s/body" filename) in
	let mwin_iounit = fopen conn mwin_fid oWRITE in
	
		(*write in the new window*)
	let (_:int32) = write conn mwin_fid mwin_iounit 0L 4l "baz\n" in
	()
)
