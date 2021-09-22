open Transaction

module type Block = sig 

  type t

  val block_to_yojson : t -> Yojson.Safe.t
  
  val block_list_to_yojson : t list -> Yojson.Safe.t
  
  val block_of_yojson : Yojson.Safe.t -> t
  
  val block_list_of_yojson : Yojson.Safe.t -> t list

  val create : nonce:int -> transactions:Transaction.t list -> prev_hash:string -> t

  val to_string : t -> string
  
  val update_index : t -> int -> unit

  val update_hash : t -> string -> unit

  val get_hash : t -> string

  val get_nonce : t -> int

  val get_tx_list : t -> Transaction.t list

  val valid_crypto : t -> t -> bool

  val tx_to_string : Transaction.t -> string

end
