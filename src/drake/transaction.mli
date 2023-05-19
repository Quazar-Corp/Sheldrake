(* Transaction type *)
type t

val of_yojson : Yojson.Safe.t -> (t, string) Result.result
val to_yojson : t -> Yojson.Safe.t
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
