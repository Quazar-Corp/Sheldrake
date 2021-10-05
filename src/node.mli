type host_info

type t

external get_global_addr : unit -> string = "stub_get_global_addr"

val host_info_of_yojson : Yojson.Safe.t -> (host_info, string) Result.result

val host_info_to_yojson : host_info -> Yojson.Safe.t

val add_node : t -> host_info -> host_info

val retrieve_host_entries : host_info
