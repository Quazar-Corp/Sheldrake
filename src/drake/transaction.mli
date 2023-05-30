(* Transaction type *)
type t

(* Function to avoid inference problems *)
val init : string -> string -> float -> string -> string -> string -> t

(* Serialization functions *)
val of_yojson : Yojson.Safe.t -> (t, string) Result.result
val to_yojson : t -> Yojson.Safe.t
val to_yojson_list : t list -> Yojson.Safe.t
val of_yojson_list : Yojson.Safe.t -> t list
val to_string : t -> string

val unpack_the_transaction :
  t -> string * string * float * string * string * string

(* sign ~transaction ~private_key *)
val sign : t -> string -> string

val create :
  sender:string -> recipient:string -> amount:float -> key:string -> t

(* Generate the hash of the merkle root *)
val calculate_merkle_root : t list -> string

(* Valid transaction = valid signature *)
val is_valid : t -> bool

(* Mempool length *)
val length : t list -> int

(* Add a transaction *)
val add_transaction : t list -> t -> t list

(* Visualization purposes -> get five random transactions *)
val five_transactions : t list -> t list

(* Verify the transactions in the mempool *)
val is_valid_mempool : t list -> bool
