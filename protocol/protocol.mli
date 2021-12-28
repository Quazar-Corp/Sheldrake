(* Share to the network the new node *)
val update_nodes_on_network : Node.host_info -> unit Lwt.t

(* Share to the network the new chain *)
val update_chain_on_network : Node.host_info -> unit Lwt.t

(* Share to the network the new mempool *)
val update_mempool_on_network : Node.host_info -> unit Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_chain : Node.host_info -> Chain.t -> bool Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_nodes : Node.host_info -> Node.t -> bool Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_mempool : Node.host_info -> Mempool.t -> bool Lwt.t
