open Drake

let read_network =
  [%rapper
    get_many
      {sql|
            SELECT @string{hostname}, @string{address}
            FROM network;
          |sql}
      function_out]
    (fun ~hostname ~address -> Node.init hostname address)
    ()

let update_network =
  [%rapper
    execute
      {sql|
            INSERT INTO network (hostname, address)
            VALUES (%string{hostname}, %string{address});
        |sql}]

let insert_transaction =
  [%rapper
    execute
      {sql|
            INSERT INTO mempool (sender, recipient, amount, timestamp, key, signature)
            VALUES 
                (%string{sender}, 
                %string{recipient}, 
                %float{amount}, 
                %string{timestamp}, 
                %string{key}, 
                %string{signature});
        |sql}]

let read_mempool =
  [%rapper
    get_many
      {sql|
            SELECT @string{sender}, 
                   @string{recipient},
                   @float{amount},
                   @string{timestamp},
                   @string{key},
                   @string{signature}
            FROM mempool;
          |sql}
      function_out]
    (fun ~sender ~recipient ~amount ~timestamp ~key ~signature ->
      Transaction.init sender recipient amount timestamp key signature)
    ()

let insert_block =
  [%rapper
    execute
      {sql|
            INSERT INTO chain (index, timestamp, nonce, merkle_root, transactions, prev_hash, hash)
            VALUES 
                (%int{index}, 
                %string{timestamp}, 
                %int{nonce}, 
                %string{merkle_root}, 
                %string{transactions}, 
                %string{prev_hash},
                %string{hash});
        |sql}]

let read_chain =
  [%rapper
    get_many
      {sql|
            SELECT @int{index}, 
                   @string{timestamp}, 
                   @int{nonce}, 
                   @string{merkle_root}, 
                   @string{transactions}, 
                   @string{prev_hash},
                   @string{hash}
            FROM chain;
          |sql}
      function_out]
    (fun ~index ~timestamp ~nonce ~merkle_root ~transactions ~prev_hash ~hash ->
      let transactions' =
        Yojson.Safe.from_string transactions
        |> Mempool.of_yojson |> Mempool.to_tx_list
      in
      Block.init index timestamp nonce merkle_root transactions' prev_hash hash)
    ()
