(* ip list to make the requests *)
val get_address_list : Node.t -> unit

(* Share to the network the new node *)
val update_nodes_on_network : Node.t -> unit

(* Share to the network the new chain *)
val update_chain_on_network : Sheldrake.t -> unit

(* Share to the network the new mempool *)
val update_mempool_on_network : Mempool.t -> unit
