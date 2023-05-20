type t

val init :
  int -> string -> int -> string -> Transaction.t list -> string -> string -> t

val of_yojson : Yojson.Safe.t -> (t, string) Result.result
val to_yojson : t -> Yojson.Safe.t

val create :
  nonce:int -> transactions:Transaction.t list -> prev_hash:string -> t

val unpack_the_block :
  t -> int * string * int * string * Transaction.t list * string * string

val to_string : t -> string
val update_index : t -> int -> unit
val update_hash : t -> string -> unit
val get_hash : t -> string
val get_nonce : t -> int
val get_tx_list : t -> Transaction.t list
val valid_crypto : t -> t -> bool
val verify_merkle_root : t -> bool
val tx_to_string : Transaction.t -> string
