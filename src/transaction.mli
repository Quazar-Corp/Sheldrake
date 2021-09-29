(* Transaction type *)
type t

val to_yojson : t -> Yojson.Safe.t

val of_yojson : Yojson.Safe.t -> t

val to_string : t -> string

val create : string -> string -> float -> t
