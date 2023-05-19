type query
type host_info
type t

(* Function to avoid inference problems *)
val init : string -> string -> host_info

(* Compare host infos *)
val ( = ) : host_info -> host_info -> bool

(* host info from query *)
val query_to_host_info : query -> host_info

(* host info to query *)
val host_info_to_query : int -> host_info -> query

(* External function to retrieve ip address with global scope *)
external get_global_addr : unit -> string = "stub_get_global_addr"

(* Network length *)
val length : t -> int

(* Due to lack of knownledge on type driven design *)
val extract_list : t -> host_info list
val unpack_the_node : host_info -> string * string

(* yojson generated function *)
val host_info_of_yojson : Yojson.Safe.t -> (host_info, string) Result.result

(* yojson generated function *)
val host_info_to_yojson : host_info -> Yojson.Safe.t

(* Node list from json *)
val of_yojson : Yojson.Safe.t -> t

(* Node list to json *)
val to_yojson : t -> Yojson.Safe.t

(* Add a new node to the network *)
val add_node : t -> host_info -> t

(* retrieve loopback global scope ip and localhost name*)
val retrieve_host_entries : host_info

(* get node ip *)
val addr : host_info -> string

(* get node hostname *)
val name : host_info -> string

(* Check if the current is already registered *)
val check_current_node_on_network : host_info list -> host_info -> bool
