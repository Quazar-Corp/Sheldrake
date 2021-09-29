type t = Block.t list

type mempool = Transaction.t list

(* Chain to json *)
let to_yojson chain =
  Block.list_to_yojson chain

(* Json to chain *)
let of_yojson json =
  Block.list_of_yojson json

(* Target of zeros *)
let target = 4

(* Range for random library *)
let bound32int = 2147483647

(* Chain size *)
let length chain =
  List.length chain

(* Returns the last block *)
let get_previous_block chain =
  (* List is storage with the genesis block on the end *)
  List.nth (List.rev chain) ((List.length chain) - 1)

(* Generates a string with a number of zeros defined as the target *)
let generate_target =
  let rec aux acc count = 
    if count = target then acc 
    else aux ("0" ^ acc) (count+1)
  in aux "" 0

(* Hashing with nonce concatened *)
let hash_of_nonce str nonce =
  Sha256.to_hex (Sha256.string (nonce ^ str))

(* Get hash from block json *)
let hash_of_string str =
  Sha256.to_hex (Sha256.string str)

(* Create transaction *)
let add_transaction ~from_ ~to_ ~amount ~mempool =
  Transaction.create from_ to_ amount
  |> fun tx -> tx :: mempool
  |> fun _ -> ()

(* Add new block to the chain *)
let add_block block chain =
  let idx = List.length chain
  in
  Block.update_index block idx
  |> fun () -> Block.update_hash block (hash_of_string (Block.to_string block))
  |> fun () -> block :: chain


(* mine function (correct nonce version)*)
let proof_of_work prev_nonce =
  let rec pow a = function
    | 0 -> 1
    | 1 -> a
    | n -> pow a (n/2)
  in
  let fingerprint current_nonce = (* Correct version -> compare prev block nonce to found current block golden nonce *)
    Int.to_string ((pow (Int32.to_int current_nonce) 2) + (pow prev_nonce 2))  
  in
  let rec aux nonce =
    let hash = hash_of_string (fingerprint nonce)
    in
    if (String.compare (String.sub hash 0 target) generate_target) = 0 then
      Printf.printf "Hash: %s | Golden Nonce: %s\n%!" hash (Int32.to_string nonce) (* Golden Nonce found! *)
      |> fun () -> (Int32.to_int nonce)
    else Printf.printf "Hash: %s | Nonce: %s\n%!" hash (Int32.to_string nonce)
         |> fun () -> aux (Random.int32 (Int32.of_int bound32int))
  in
  aux (Random.int32 (Int32.of_int bound32int))

(* Chain validation *)
let chain_is_valid chain =
  let rec aux = function
    | [] | _ :: [] -> true (* end of the list *)
    | prev :: (curr :: _ as tl) -> if (Block.valid_crypto prev curr) then aux tl
      else false
  in aux chain

(* Mining one block *)
let mine_block chain transactions =
  let nonce = (proof_of_work (Block.get_nonce (get_previous_block chain))) (* last block nonce *)
  in
  let prev_hash = Block.get_hash (get_previous_block chain) (* last block hash *)
  in
  Block.create ~nonce ~transactions ~prev_hash
