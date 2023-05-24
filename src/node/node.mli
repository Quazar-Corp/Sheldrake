type query
type t

(* Function to avoid inference problems *)
val init : string -> string -> t

(* Compare host infos *)
val ( = ) : t -> t -> bool

(* host info from query *)
val query_to_t : query -> t

(* host info to query *)
val t_to_query : int -> t -> query

(* External function to retrieve ip address with global scope *)
external get_global_addr : unit -> string = "stub_get_global_addr"

(* Network length *)
val length : t list -> int

(* Due to lack of knownledge on type driven design *)
val extract_list : t list -> t list
val unpack_the_node : t -> string * string

(* yojson generated function *)
val of_yojson : Yojson.Safe.t -> (t, string) Result.result

(* yojson generated function *)
val to_yojson : t -> Yojson.Safe.t

(* Node list from json *)
val of_yojson_list : Yojson.Safe.t -> t list

(* Node list to json *)
val to_yojson_list : t list -> Yojson.Safe.t

(* Add a new node to the network *)
val add_node : t -> t list -> t list

(* retrieve loopback global scope ip and localhost name*)
val retrieve_host_entries : t

(* get node ip *)
val addr : t -> string

(* get node hostname *)
val name : t -> string

(* Check if the current is already registered *)
val check_current_node_on_network : t -> t list -> bool
