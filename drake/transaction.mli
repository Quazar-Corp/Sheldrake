(* Transaction type *)
type t

val of_yojson : Yojson.Safe.t -> (t, string) Result.result

val to_yojson : t -> Yojson.Safe.t

val to_string : t -> string

val create : sender:string -> recipient:string -> amount:float -> key:string -> t

(* sign ~transaction ~private_key *)
val sign : t -> string -> unit
