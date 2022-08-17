(*open Drake*)

(* Migrate the database *)
(*val migrate : unit -> unit*)

(*
(* Retrieve all the entire blockchain *)
val get_chain : unit -> Chain.t Lwt.t

(* Insert a successful mined block on the chain *)
val insert_block : Block.t -> unit Lwt.t

(* Replace chain *)
val replace_chain : Chain.t -> unit Lwt.t 

(* Retrieve the UTXOs list *)
val get_mempool : unit -> Mempool.t Lwt.t

(* Insert a transaction on the mempool *)
val insert_transaction : Transaction.t -> unit Lwt.t

(* Replace transaction list *)
val replace_mempool : Mempool.t -> unit Lwt.t 

(* Retrieve all nodes in the network *)
val get_network : unit -> Node.t Lwt.t

(* Update node list *)
val update_nodes : Node.host_info -> unit Lwt.t 

(* Replace network list *)
val replace_network : Node.t -> unit Lwt.t 
*)
