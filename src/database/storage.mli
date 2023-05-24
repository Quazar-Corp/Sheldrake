open Drake

(* Retrieve all the entire blockchain !DEPRECATED! *)
val get_chain : unit -> Block.t list Lwt.t

(* Insert a successful mined block on the chain !DEPRECATED! *)
val insert_block : Block.t -> unit Lwt.t

(* Replace chain *)
val replace_chain : Block.t list -> unit Lwt.t

(* Retrieve the UTXOs list !DEPRECATED! *)
val get_mempool : unit -> Transaction.t list Lwt.t

(* Insert a transaction on the mempool !DEPRECATED! *)
val insert_transaction : Transaction.t -> unit Lwt.t

(* Replace transaction list *)
val replace_mempool : Transaction.t list -> unit Lwt.t

(* Retrieve all nodes in the network !DEPRECATED! *)
val get_network : unit -> Node.t list Lwt.t

(* Update node list !DEPRECATED! *)
val update_nodes : Node.t -> unit Lwt.t

(* Replace network list *)
val replace_network : Node.t list -> unit Lwt.t
