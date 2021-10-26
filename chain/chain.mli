open Drake

type t

(* Chain to json *)
val to_yojson : t -> Yojson.Safe.t

(* Json to chain *)
val of_yojson : Yojson.Safe.t -> t

(* Target of zeros *)
val target : int

(* Range for random library *)
val bound32int : int

(* Chain size *)
val length : t -> int

(* Returns the last block *)
val get_previous_block : t -> Block.t

(* Generates a string with a number of zeros defined as the target *)
val generate_target : string

(* Get hash from block json *)
val hash_of_string : string -> string

(* Add new block to the chain *)
val add_block : t -> Block.t -> t

(* mine function (correct nonce version)*)
val proof_of_work : int -> int

(* Chain validation *)
val chain_is_valid  : t -> bool

(* Mining one block *)
val mine_block : t -> Transaction.t list -> Block.t

(* Replace chain after requests *)
val replace_chain : Block.t list list -> int -> t

