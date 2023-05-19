(* Transaction type *)
(* Serializable record *)
type t = {
  sender : string;
  recipient : string;
  amount : float;
  timestamp : string;
  key : string;
  mutable signature : string;
}
[@@deriving yojson]

let to_string tx =
  tx.sender ^ tx.recipient ^ Float.to_string tx.amount ^ tx.timestamp ^ tx.key

let unpack_the_transaction tx =
  (tx.sender, tx.recipient, tx.amount, tx.timestamp, tx.key, tx.signature)

let sign tx key = Crypto.sign ~message:(to_string tx) ~key

let create ~sender ~recipient ~amount ~key =
  let raw_tx =
    {
      sender;
      recipient;
      amount;
      timestamp = Float.to_string (Unix.time ());
      key = Crypto.pub_of_priv key;
      signature = "";
    }
  in
  {
    sender = raw_tx.sender;
    recipient = raw_tx.recipient;
    amount = raw_tx.amount;
    timestamp = raw_tx.timestamp;
    key = raw_tx.key;
    signature = sign raw_tx key;
  }

let sign tx key = Crypto.sign ~message:(to_string tx) ~key

let calculate_merkle_root txs =
  let list_of_hashs =
    if List.length txs = 0 then [ String.init 64 (fun _ -> '0') ]
    else if List.length txs = 1 then
      to_string (List.hd txs) |> Sha256.string |> Sha256.to_hex |> fun str ->
      [ str ]
    else List.map (fun tx -> Sha256.to_hex (Sha256.string (to_string tx))) txs
  in
  (*let list_of_lens = if (List.length list_of_hashs) mod 2 = 0 then List.length list_of_hashs
                       else List.length (list_of_hashs @ [List.hd (List.rev list_of_hashs)])
    in*)
  let rec aux root_count = function
    | [] -> "Impossible"
    | [ root ] -> root
    | prev :: (next :: _ as tl) ->
        list_of_hashs @ [ Sha256.to_hex (Sha256.string (prev ^ next)) ]
        |> fun _ -> aux (root_count - 2) tl
  in
  aux (List.length list_of_hashs) list_of_hashs
(*list_of_hashs |> fun _ -> list_of_lens |> fun _ -> "Need to study merkle tree"*)

let is_valid tx =
  if
    Crypto.verify_signature ~signature:tx.signature ~key:tx.key
      ~message:(to_string tx)
  then true
  else false
