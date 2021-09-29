type t

val to_yojson : t -> Yojson.Safe.t

val of_yojson : Yojson.Safe.t -> t

val target : int

val bound32int : int

val length : t -> int

val get_transactions : t -> Transaction.t list

val get_previous_block : t -> Block.t

val generate_target : string

val hash_of_nonce : string -> string -> string

val hash_of_string : string -> string

val add_transaction : t -> from_:string -> to_:string -> amount:float -> unit 

val add_block : Block.t -> t -> t

val proof_of_work : int -> int

val chain_is_valid  : t -> bool

val mine_block : t -> Transaction.t list -> Block.t

