open Drake

let ensure_table_chain_exists =
  [%rapper
    execute
      {sql|
                CREATE TABLE IF NOT EXISTS chain (
                    id SERIAL PRIMARY KEY NOT NULL,
                    index INT NOT NULL, 
                    timestamp VARCHAR NOT NULL,
                    nonce INT NOT NULL,
                    merkle_root VARCHAR NOT NULL,
                    transactions JSONB NULL,
                    prev_hash VARCHAR NOT NULL,
                    hash VARCHAR NOT NULL
                );
            |sql}]
    ()

let ensure_table_mempool_exists =
  [%rapper
    execute
      {sql|
                CREATE TABLE IF NOT EXISTS mempool (
                    id SERIAL PRIMARY KEY NOT NULL,
                    sender VARCHAR NOT NULL,
                    recipient VARCHAR NOT NULL,
                    amount FLOAT NOT NULL,
                    timestamp VARCHAR NOT NULL,
                    key VARCHAR NOT NULL,
                    signature VARCHAR NOT NULL
                );
            |sql}]
    ()

let ensure_table_network_exists =
  [%rapper
    execute
      {sql|
                CREATE TABLE IF NOT EXISTS network (
                    id SERIAL PRIMARY KEY NOT NULL,
                    hostname VARCHAR NOT NULL,
                    address VARCHAR NOT NULL
                );
            |sql}]
    ()

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
        Yojson.Safe.from_string transactions |> Transaction.of_yojson_list
      in
      Block.init index timestamp nonce merkle_root transactions' prev_hash hash)
    ()
