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

let calculate_merkle_root txs =
  let list_of_hashs = if (List.length txs) = 0 then [String.init 64 (fun _ -> '0')]
                      else if (List.length txs) = 1 then to_string (List.hd txs)
                                                         |> Sha256.string 
                                                         |> Sha256.to_hex
                                                         |> fun str -> [str]                              
                      else List.map (fun tx -> Sha256.to_hex (Sha256.string (to_string tx))) txs
  in
  list_of_hashs |> fun _ -> "Need to study merkle tree"

