
(* Retrieve the blockchain network (all the nodes)*)
val read_network : (module Rapper_helper.CONNECTION) -> (Node.host_info list, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new node in the blockchain network *)
val update_network : hostname:string -> address:string -> (module Rapper_helper.CONNECTION) -> (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t
