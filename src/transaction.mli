(* Type transaction *)
module type Tx = sig 

  type t

  val to_string : t -> string

  val to_yojson : t -> Yojson.Safe.t

  val of_yojson : Yojson.Safe.t -> t

end

(* Type list of transactions *)

module type TxList = sig 

  type t

  val to_string : t -> string

  val to_yojson : t -> Yojson.Safe.t

  val of_yojson : Yojson.Safe.t -> t

  val sign : string -> unit

end

