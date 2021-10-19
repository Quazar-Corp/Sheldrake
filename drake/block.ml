(* Block type *)
(* Serializable record *)
type t = {
  mutable block_index : int;
  timestamp : string;
  nonce : int;
  transactions : Transaction.t list;
  prev_hash : string;
  mutable hash : string;
}[@@deriving yojson]

(* Block to json *)
let list_to_yojson chain =
  [%to_yojson: t list] chain

(* Json to Block *)
let list_of_yojson json =
  match [%of_yojson: t list] json with
    | Ok chain -> chain
    | Error err -> err |> fun _ -> raise Parsing.Parse_error

(* Return a new block *)
let create ~nonce ~transactions ~prev_hash =
  let timestamp = Float.to_string (Unix.time ())
  in
  {block_index=0; timestamp=timestamp; nonce=nonce; 
   transactions=transactions; prev_hash=prev_hash; hash=""}

(* Update index with the current position in chain *)
let update_index block idx =
  block.block_index <- idx;
  ()

(* In case the fingerprint changes(avalanche effect) *)
let update_hash block hash =
  block.hash <- hash;
  ()

(* Retrieve block hash *)
let get_hash block =
  block.hash

(* Retrieve block nonce *)
let get_nonce block =
  block.nonce

(* Return the list of transactions of a block *)
let get_tx_list block =
  block.transactions

(* Verify with the is correct linked with crypto *)
let valid_crypto prev curr =
  String.equal prev.hash curr.prev_hash

(* String representation of the block *)
let to_string block =
  (Int.to_string block.block_index) ^ " " ^
  block.timestamp  ^ " " ^
  (Int.to_string block.nonce) ^ " " ^
  block.prev_hash  ^ " " 

(* Transaction list to string *)
let tx_to_string tx = 
  Transaction.to_string tx

