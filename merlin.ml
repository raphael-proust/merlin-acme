open Batteries
module Json = Yojson.Basic
type state = IO.input * unit IO.output

let start command args = 
  Unix.open_process ~autoclose: true ~cleanup: true 
    (Printf.sprintf "%s %s"
       command (String.concat " " (List.map Filename.quote args)))

let close (input, output) =
  Unix.close_process (input, output)

type position = int * int
type result = 
| Return of Json.json
| Error of string

let string_of_json = function `String s -> s | _ -> assert false
let int_of_json = function `Int n -> n | _ -> assert false
let pos_of_json a = match a with
  | `Assoc l ->
    int_of_json (List.assoc "line" l), int_of_json (List.assoc "col" l)
  | _ -> (-1, -1)

let json_of_pos (a, b) = 
  `Assoc ["line", `Int a; "col", `Int b]

let json_of_range (start, stop) =
  `Assoc ["start", json_of_pos start; 
          "stop", json_of_pos stop]

let range_of_json = function
  | `Assoc l -> pos_of_json (List.assoc "start" l), pos_of_json (List.assoc "end" l)

let send_command (input, output) command args = 
  Printf.fprintf output "%s\n" (Json.to_string (`List (`String command :: args)));
  Printf.fprintf stdout "%s\n" (Json.to_string (`List (`String command :: args)));
  flush output;
  let s = IO.read_line input in
  print_endline s;
  match Json.from_string s with
  | `List ([`String "return"; data]) -> Return data
  | `List ([`String "error"; `String s]) -> Error s
  | `List ([`String "failure"; `String s]) -> Error s
  | _ -> Error ("Unknown JSON")

let send_command_map ~state command args cb = 
  match send_command state command args with
  | Return a -> (try Some (cb a) with _ -> None)
  | Error s -> prerr_endline s; None
let load_project ~state filename = 
  send_command_map ~state "project" [`String "find"; `String filename] 
    (function 
    | `List l -> List.map string_of_json l | _ -> assert false)

let reset ~state filename = 
  send_command_map ~state "reset" [`String "name"; `String filename] (fun _ -> ())


let tell_more ~state code = 
  send_command_map ~state "tell" [`String "more"; `String code] 
    (function `Null -> None
    | `Assoc _ as data -> Some (pos_of_json data)
    | _ -> assert false)

let tell_source ~state code = 
  send_command_map ~state "tell" [`String "source"; `String code] (fun _ -> ())
let tell_end ~state = send_command_map ~state "tell" [`String "end"]
    (function `Null -> None
    | `Assoc _ as data -> Some (pos_of_json data)
    | _ -> assert false)

let tell_string ~state code = 
  Option.bind (tell_source ~state code) (fun () ->
    tell_end ~state)

let type_enclosing ~state (string, offset) pos = 
  send_command_map ~state "type" 
    [`String "enclosing"; 
     `Assoc ["expr", `String string; "offset", `Int offset]; 
     json_of_pos pos]
    (function `List l ->
      List.map (function 
      | `Assoc l as data -> (string_of_json (List.assoc "type" l), range_of_json data)
      | _ -> assert false) l
    | _ -> assert false)

let locate ~state identifier position = 
  send_command_map ~state "locate" [`String identifier; `String "at"; json_of_pos position] 
    (function
    | `Assoc l -> (string_of_json (List.assoc "file" l), pos_of_json (List.assoc "pos" l))
    | _ -> assert false)

let errors ~state = 
  send_command_map ~state "errors" [] (function
  | `List e ->
    List.map (function
    | `Assoc l as data -> string_of_json (List.assoc "message" l), range_of_json data
    | _ -> assert false) e
  | _ -> assert false)

type completion_entry = {
  kind : string;
  descr : string;
  name: string;
}

let complete ~state ident position = 
  send_command_map ~state "complete" [`String "prefix"; `String ident; `String "at"; json_of_pos position] (function
  | `List e ->
    List.map (function
    | `Assoc l -> 
      { kind = string_of_json (List.assoc "kind" l);
        name = string_of_json (List.assoc "name" l);
        descr = string_of_json (List.assoc "desc" l) }
    | _ -> assert false) e
  | _ -> assert false)
let type_expression ~state string pos = 
  send_command_map ~state "type" 
    [`String "expression"; `String string; `String "at"; json_of_pos pos]
    (function `String s -> s
    | _ -> assert false)
