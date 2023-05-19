(* Block type *)
(* Serializable record *)
type t = {
  mutable index : int;
  timestamp : string;
  nonce : int;
  merkle_root : string;
  transactions : Transaction.t list;
  prev_hash : string;
  mutable hash : string;
}
[@@deriving yojson]

(* Return a new block *)
let create ~nonce ~transactions ~prev_hash =
  let timestamp = Float.to_string (Unix.time ()) in
  let merkle_root = Transaction.calculate_merkle_root transactions in
  {
    index = 0;
    timestamp;
    nonce;
    merkle_root;
    transactions;
    prev_hash;
    hash = "";
  }

(* Update index with the current position in chain *)
let update_index block idx =
  block.index <- idx;
  ()

(* In case the fingerprint changes(avalanche effect) *)
let update_hash block hash =
  block.hash <- hash;
  ()

(* Retrieve block hash *)
let get_hash block = block.hash

(* Retrieve block nonce *)
let get_nonce block = block.nonce

(* Return the list of transactions of a block *)
let get_tx_list block = block.transactions

(* Verify with the is correct linked with crypto *)
let valid_crypto prev curr = String.equal prev.hash curr.prev_hash

let verify_merkle_root block =
  String.equal block.merkle_root
    (Transaction.calculate_merkle_root block.transactions)

(* String representation of the block *)
let to_string block =
  Int.to_string block.index ^ " " ^ block.timestamp ^ " "
  ^ Int.to_string block.nonce ^ " " ^ block.merkle_root ^ " " ^ block.prev_hash
  ^ " "

(* Transaction list to string *)
let tx_to_string tx = Transaction.to_string tx
