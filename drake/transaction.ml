(* Transaction type *)
(* Serializable record *) 
type t = {
  sender : string;
  receiver : string;
  amount : float;
}[@@deriving yojson]

let to_string tx =
  tx.sender ^ tx.receiver ^ (Float.to_string tx.amount)

let create sender receiver amount =
  {sender=sender; receiver=receiver; amount=amount}

