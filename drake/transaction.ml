(* Transaction type *)
(* Serializable record *) 
type t = {
  from_ : string;
  to_ : string;
  amount : float;
}[@@deriving yojson]

let to_string tx =
  tx.from_ ^ tx.to_ ^ (Float.to_string tx.amount)

let create from_ to_ amount =
  {from_=from_; to_=to_; amount=amount}

