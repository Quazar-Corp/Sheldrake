(* Elliptic curve parameters -> SECP256K1 *)

(* Auxiliar function to operations *)
val pow : int -> int -> int

(* Impure function that affects primitive values of the curve *)
val change_curve : p:int -> n:int64 -> a:int -> b:int -> gx:int64 -> gy:int64 -> unit


