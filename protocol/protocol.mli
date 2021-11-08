(* Share to the network the new node *)
val update_nodes_on_network : Node.host_info -> unit Lwt.t

(* Share to the network the new chain *)
val update_chain_on_network : Node.host_info -> unit Lwt.t

(* Share to the network the new mempool *)
val update_mempool_on_network : Node.host_info -> unit Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update : current_node:Node.host_info -> list_to_verify:'a list -> 
  name_to_verify:string -> decode_func:(Yojson.Safe.t -> 'a list) -> bool Lwt.t
