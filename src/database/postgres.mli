open Drake

(* Migrate the database *)
val migrate : unit -> unit

(* READ the all the nodes registered *)
val get_network : unit -> Node.host_info list Lwt.t

(* UPDATE the network with a new node | INSERT a new node in the network --> which is better?*)
val update_network : Node.host_info -> unit Lwt.t

(* INSERT a validated transaction in Mempool *)
val insert_transaction : Drake.Transaction.t -> unit Lwt.t

(* READ all the transactions in the Mempool *)
val get_mempool : unit -> Transaction.t list Lwt.t
