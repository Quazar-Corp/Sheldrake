(* Transaction type *)
type t

val of_yojson : Yojson.Safe.t -> (t, string) Result.result

val to_yojson : t -> Yojson.Safe.t

val to_string : t -> string

val create : string -> string -> float -> t
