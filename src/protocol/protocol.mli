open Drake

(* Share to the network the new node *)
val update_nodes_on_network : Node.t -> unit Lwt.t

(* Share to the network the new chain *)
val update_chain_on_network : Node.t -> unit Lwt.t

(* Share to the network the new mempool *)
val update_mempool_on_network : Node.t -> unit Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_chain : Node.t -> Block.t list -> bool Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_nodes : Node.t -> Node.t list -> bool Lwt.t

(* Consensus protocol to avoid byzantine fault *)
val consensus_update_mempool : Node.t -> Transaction.t list -> bool Lwt.t
