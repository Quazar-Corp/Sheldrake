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

let init index timestamp nonce merkle_root transactions prev_hash hash =
  { index; timestamp; nonce; merkle_root; transactions; prev_hash; hash }

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

let update_index block idx =
  block.index <- idx;
  ()

let update_hash block hash =
  block.hash <- hash;
  ()

let get_hash block = block.hash
let get_nonce block = block.nonce
let get_tx_list block = block.transactions
let valid_crypto prev curr = String.equal prev.hash curr.prev_hash

let verify_merkle_root block =
  String.equal block.merkle_root
    (Transaction.calculate_merkle_root block.transactions)

let to_string block =
  Int.to_string block.index ^ " " ^ block.timestamp ^ " "
  ^ Int.to_string block.nonce ^ " " ^ block.merkle_root ^ " " ^ block.prev_hash
  ^ " "

let unpack_the_block block =
  ( block.index,
    block.timestamp,
    block.nonce,
    block.merkle_root,
    block.transactions,
    block.prev_hash,
    block.hash )

let txs_to_string tx = Transaction.to_string tx
let to_yojson_list chain = [%to_yojson: t list] chain

let of_yojson_list json =
  match [%of_yojson: t list] json with
  | Ok chain -> chain
  | Error err -> err |> fun _ -> raise Parsing.Parse_error

let target = 4
let bound32int = 2147483647

let get_previous_block chain =
  (* List is storage with the genesis block on the end *)
  List.nth (List.rev chain) (List.length chain - 1)

let generate_target =
  let rec aux acc count =
    if count = target then acc else aux ("0" ^ acc) (count + 1)
  in
  aux "" 0

let hash_of_string str = Sha256.to_hex (Sha256.string str)

let add_block block chain =
  let idx = List.length chain in
  update_index block idx |> fun () ->
  update_hash block (hash_of_string (to_string block)) |> fun () ->
  block :: chain

let genesis_block =
  let block =
    create ~nonce:0 ~transactions:[] ~prev_hash:(String.init 64 (fun _ -> '0'))
  in
  update_hash block (hash_of_string (to_string block));
  block

let proof_of_work prev_nonce =
  let rec pow a = function 0 -> 1 | 1 -> a | n -> pow a (n / 2) in
  let fingerprint current_nonce =
    (* Correct version -> compare prev block nonce to found current block golden nonce *)
    Int.to_string (pow (Int32.to_int current_nonce) 2 + pow prev_nonce 2)
  in
  let rec aux nonce =
    let hash = hash_of_string (fingerprint nonce) in
    if String.compare (String.sub hash 0 target) generate_target = 0 then
      Printf.printf "Hash: %s | Golden Nonce: %s\n%!" hash
        (Int32.to_string nonce)
      (* Golden Nonce found! *)
      |> fun () -> Int32.to_int nonce
    else
      Printf.printf "Hash: %s | Nonce: %s\n%!" hash (Int32.to_string nonce)
      |> fun () -> aux (Random.int32 (Int32.of_int bound32int))
  in
  aux (Random.int32 (Int32.of_int bound32int))

let is_valid_chain chain =
  let rec aux = function
    | [] -> true (* end of the list *)
    | [ block ] -> if verify_merkle_root block then true else false
    | prev :: (curr :: _ as tl) ->
        if valid_crypto prev curr && verify_merkle_root prev then aux tl
        else false
  in
  aux chain

let mine_block transactions chain =
  let nonce =
    proof_of_work (get_nonce (get_previous_block chain))
    (* last block nonce *)
  in
  let prev_hash = get_hash (get_previous_block chain) (* last block hash *) in
  create ~nonce ~transactions ~prev_hash

let replace_chain chain_list max_length =
  let rec aux bigger size = function
    | [] -> bigger
    | hd :: tl ->
        if List.length hd > size then aux hd size tl else aux bigger size tl
  in
  aux [] max_length chain_list
