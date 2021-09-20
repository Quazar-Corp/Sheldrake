open Transaction

module Block : sig 

  type t

  val block_to_yojson : t -> Yojson.Safe.t
  
  val block_list_to_yojson : t list -> Yojson.Safe.t
  
  val block_of_yojson : Yojson.Safe.t -> t
  
  val block_list_of_yojson : Yojson.Safe.t -> t list

  val create : nonce:int -> transactions: Transaction.t list -> prev_hash:string -> t

  val to_string : t -> string
  
  val update_index : t -> int -> unit

  val update_hash : t -> string -> unit

  val get_hash : t -> string

  val get_nonce : t -> int

  val get_tx_list : t -> Transaction.t list

  val valid_crypto : t -> t -> bool

  val tx_to_string : Transaction.t -> string

end = struct 

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

  (* Jsonify a block *)
  let block_to_yojson block =
    [%to_yojson: t] block

  (* Jsonify a block list *)
  let block_list_to_yojson blockchain =
    [%to_yojson: t list] blockchain

  (* Blockfy a json *)
  let block_of_yojson json =
    match [%of_yojson: t] json with
    | Ok block -> block
    | Error err -> err |> fun _ -> raise Parsing.Parse_error

  (* listfy a json *)
  let block_list_of_yojson json =
    match [%of_yojson: t list] json with
    | Ok blockchain -> blockchain
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

end
