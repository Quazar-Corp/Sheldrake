(* Transaction type *)
(* Serializable record *) 
module Transaction : sig

  type t

  val to_string : t -> string

  val to_yojson : t -> Yojson.Safe.t

  val of_yojson : Yojson.Safe.t -> t

  val create : string -> string -> float -> t

end = struct 
  
  type t = {
    from_ : string;
    to_ : string;
    amount : float;
  }[@@deriving yojson]

  let to_string tx =
    tx.from_ ^ tx.to_ ^ (Float.to_string tx.amount)

  let to_yojson tx =
    [%to_yojson: t] tx

  let of_yojson json =
    match [%of_yojson: t] json with
    | Ok tx -> tx
    | Error err -> raise (Invalid_argument err)

  let create from_ to_ amount =
    {from_=from_; to_=to_; amount=amount}

end
