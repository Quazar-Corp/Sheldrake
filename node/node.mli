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

(* retrieve loopback global scope ip and localhost name*)
val retrieve_host_entries : host_info

(* get node ip *)
val addr : host_info -> string

(* get node hostname *)
val name : host_info -> string

(* ip list to make the requests *)
val get_address_list : t -> unit

