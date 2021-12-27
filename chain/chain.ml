open Drake

type t = Block.t list

let to_yojson chain =
  [%to_yojson: Block.t list] chain

let of_yojson json =
  match [%of_yojson: Block.t list] json with
    | Ok chain -> chain
    | Error err -> err |> fun _ -> raise Parsing.Parse_error

let target = 4

let bound32int = 2147483647

let length chain =
  List.length chain

let get_previous_block chain =
  (* List is storage with the genesis block on the end *)
  List.nth (List.rev chain) ((List.length chain) - 1)

let generate_target =
  let rec aux acc count = 
    if count = target then acc 
    else aux ("0" ^ acc) (count+1)
  in aux "" 0

let hash_of_string str =
  Sha256.to_hex (Sha256.string str)

let add_block chain block =
  let idx = List.length chain
  in
  Block.update_index block idx
  |> fun () -> Block.update_hash block (hash_of_string (Block.to_string block))
  |> fun () -> block :: chain


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

let chain_is_valid chain =
  let rec aux = function
    | [] | _ :: [] -> true (* end of the list *)
    | prev :: (curr :: _ as tl) -> if (Block.valid_crypto prev curr) then aux tl
      else false
  in aux chain

let mine_block chain transactions =
  (* Verification to generate the genesis block *)
  if List.length chain = 0 then Block.create ~nonce:0 ~transactions:[] ~prev_hash:(String.init 64 (fun _ -> '0'))
  else let nonce = (proof_of_work (Block.get_nonce (get_previous_block chain))) (* last block nonce *)
  in
  let prev_hash = Block.get_hash (get_previous_block chain) (* last block hash *)
  in
  Block.create ~nonce ~transactions ~prev_hash

let replace_chain chain_list max_length =
  let rec aux bigger size = function
    | [] -> bigger
    | hd :: tl -> if (List.length hd) > size then aux hd size tl
                  else aux bigger size tl
  in
  aux [] max_length chain_list 

