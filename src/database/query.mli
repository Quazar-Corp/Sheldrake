open Drake

(* CHAIN TABLE *)
val ensure_table_chain_exists : 
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* MEMPOOL TABLE *)
val ensure_table_mempool_exists : 
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* NETWORK TABLE *)
val ensure_table_network_exists : 
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Retrieve the blockchain network (all the nodes)*)
val read_network :
  (module Rapper_helper.CONNECTION) ->
  (Node.t list, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new node in the blockchain network *)
val update_network :
  hostname:string ->
  address:string ->
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new transaction in the mempool *)
val insert_transaction :
  sender:string ->
  recipient:string ->
  amount:float ->
  timestamp:string ->
  key:string ->
  signature:string ->
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Retrieve the network's mempool (all available transactions)*)
val read_mempool :
  (module Rapper_helper.CONNECTION) ->
  (Transaction.t list, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Insert the new block in the chain *)
val insert_block :
  index:int ->
  timestamp:string ->
  nonce:int ->
  merkle_root:string ->
  transactions:string ->
  prev_hash:string ->
  hash:string ->
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t

(* Retrieve the network's chain*)
val read_chain :
  (module Rapper_helper.CONNECTION) ->
  (Block.t list, [> Caqti_error.call_or_retrieve ]) result Lwt.t
