(* Transaction type *)
(* Serializable record *) 
type t = {
  sender : string;
  recipient : string;
  amount : float;
  timestamp: string;
  key : string;
  mutable signature: string
}[@@deriving yojson]

let to_string tx =
  tx.sender ^ tx.recipient ^ (Float.to_string tx.amount) ^ tx.timestamp ^ tx.key

let create ~sender ~recipient ~amount ~key =
  {sender=sender; recipient=recipient; amount=amount; 
   timestamp=(Float.to_string (Unix.time ())); 
   key=key; signature=""}

let sign tx key =
  let signature = Crypto.sign ~message:(to_string tx) ~key:key
  in
  (tx.signature <- signature) |> fun _ -> ()
