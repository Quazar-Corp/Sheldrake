(* Transaction type *)
(* Serializable record *) 
type t = {
  sender : string;
  recipient : string;
  amount : float;
  timestamp: string;
  signature: string
}[@@deriving yojson]

let to_string tx =
  tx.sender ^ tx.recipient ^ (Float.to_string tx.amount) ^ tx.timestamp ^ tx.signature

let create sender recipient amount =
  {sender=sender; recipient=recipient; amount=amount; 
   timestamp=(Float.to_string (Unix.time ())); signature=""}

