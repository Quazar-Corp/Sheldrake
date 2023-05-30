type t

val genesis_block : t

val init :
  int -> string -> int -> string -> Transaction.t list -> string -> string -> t

(* Serialization functions *)
val of_yojson : Yojson.Safe.t -> (t, string) Result.result
val to_yojson : t -> Yojson.Safe.t
val to_string : t -> string

(* Return a new block *)
val create :
  nonce:int -> transactions:Transaction.t list -> prev_hash:string -> t

val unpack_the_block :
  t -> int * string * int * string * Transaction.t list * string * string

(* Update index with the current position in chain *)
val update_index : t -> int -> unit

(* In case the fingerprint changes(avalanche effect) *)
val update_hash : t -> string -> unit

(* Retrieve block hash *)
val get_hash : t -> string

(* Retrieve block nonce *)
val get_nonce : t -> int

(* Return the list of transactions of a block *)
val get_tx_list : t -> Transaction.t list

(* Verify with the is correct linked with crypto *)
val valid_crypto : t -> t -> bool

(* Validates the merkle root hash*)
val verify_merkle_root : t -> bool

(* Transaction list to string *)
val txs_to_string : Transaction.t -> string

(* Chain to json *)
val to_yojson_list : t list -> Yojson.Safe.t

(* Json to chain *)
val of_yojson_list : Yojson.Safe.t -> t list

(* Target of zeros *)
val target : int

(* Range for random library *)
val bound32int : int

(* Returns the last block *)
val get_previous_block : t list -> t

(* Generates a string with a number of zeros defined as the target *)
val generate_target : string

(* Get hash from block json *)
val hash_of_string : string -> string

(* Add new block to the chain *)
val add_block : t -> t list -> t list

(* mine function (correct nonce version)*)
val proof_of_work : int -> int

(* Chain validation *)
val is_valid_chain : t list -> bool

(* Mining one block *)
val mine_block : Transaction.t list -> t list -> t

(* Replace chain after requests *)
val replace_chain : t list list -> int -> t list
