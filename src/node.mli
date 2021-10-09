type host_info

type t

(* External function to retrieve ip address with global scope *)
external get_global_addr : unit -> string = "stub_get_global_addr"

(* yojson generated function *)
val host_info_of_yojson : Yojson.Safe.t -> (host_info, string) Result.result

(* yojson generated function *)
val host_info_to_yojson : host_info -> Yojson.Safe.t

(* Add a new node to the network *)
val add_node : t -> host_info -> host_info

val retrieve_host_entries : host_info

(* Retrieve node ip *)
val addr : host_info -> string

(* Retrieve node host name *)
val name : host_info -> string
