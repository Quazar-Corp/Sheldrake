open Drake

(* Retrieve all the entire blockchain *)
val get_chain : unit -> Sheldrake.t Lwt.t

(* Insert a successful mined block on the chain *)
val insert_block : Block.t -> unit Lwt.t

(* Retrieve the UTXOs list *)
val get_mempool : unit -> Mempool.t Lwt.t

(* Insert a transaction on the mempool *)
val insert_transaction : Transaction.t -> unit Lwt.t
