(* Share to the network the new node *)
val update_nodes_on_network : Node.t -> unit

(* Share to the network the new chain *)
val update_chain_on_network : 'a list -> unit

(* Share to the network the new mempool *)
val update_mempool_on_network : Drake.Mempool.t -> unit
