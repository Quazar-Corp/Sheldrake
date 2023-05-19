(*open Drake*)

(* Migrate the database *)
val migrate : unit -> unit

(* READ the all the nodes registered *)
val get_network : unit -> Node.host_info list Lwt.t 

(* UPDATE the network with a new node*)
val update_network : Node.host_info -> unit Lwt.t

(* INSERT a validated transaction in Mempool *)
val insert_transaction : Drake.Transaction.t -> unit Lwt.t
