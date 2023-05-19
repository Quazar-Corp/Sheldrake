
(* Retrieve the blockchain network (all the nodes)*)
val read_network : (module Rapper_helper.CONNECTION) -> (Node.host_info list, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new node in the blockchain network *)
val update_network : hostname:string -> address:string -> (module Rapper_helper.CONNECTION) -> (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new transaction in the mempool *)
val insert_transaction : sender:string -> recipient:string -> amount:float -> timestamp:string -> key:string -> signature:string -> (module Rapper_helper.CONNECTION) -> (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t
