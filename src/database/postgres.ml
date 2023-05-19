exception Query_failed of string

(* Setup of database pool *)
(* ********************************************************************************************* *)
let connection_url =
  "postgresql://localhost:5431/sheldrake?user=admin&password=sup3rS3cr3tP455w0rd\n\
  \                      ssl=false"

(* Pool connection to the database *)
let pool =
  match Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string connection_url) with
  | Ok pool ->
      Printf.printf ">>> Connected to database\n";
      pool
  | Error err -> failwith (Caqti_error.show err)

(* Execute the queries *)
let dispatch func =
  let open Lwt.Syntax in
  let* result = Caqti_lwt.Pool.use func pool in
  match result with
  | Ok data -> Lwt.return data
  | Error error -> Lwt.fail (Query_failed (Caqti_error.show error))
(* ********************************************************************************************* *)

(* Running migrations *)
(* ********************************************************************************************* *)
(* CHAIN TABLE *)
let ensure_table_blocks_exists =
  [%rapper
    execute
      {sql|
                CREATE TABLE IF NOT EXISTS chain (
                    id SERIAL PRIMARY KEY NOT NULL,
                    index INT NOT NULL, 
                    timestamp TIMESTAMP NOT NULL,
                    nonce INT NOT NULL,
                    merkle_root VARCHAR NOT NULL,
                    transactions JSONB NULL,
                    prev_hash VARCHAR NOT NULL,
                    hash VARCHAR NOT NULL
                );
            |sql}]
    ()

(* MEMPOOL TABLE *)
let ensure_table_transactions_exists =
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

(* NETWORK TABLE *)
let ensure_table_nodes_exist =
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

(* Running *)
let migrate () =
  Printf.printf ">>> Migrating the database\n";
  dispatch ensure_table_blocks_exists |> Lwt_main.run |> fun () ->
  dispatch ensure_table_transactions_exists |> Lwt_main.run |> fun () ->
  dispatch ensure_table_nodes_exist |> Lwt_main.run
(* ********************************************************************************************* *)

(* Queries *)
(* ********************************************************************************************* *)
let get_network () = dispatch Query.read_network

let update_network (node : Node.host_info) =
  let hostname, address = Node.unpack_the_node node in
  dispatch (Query.update_network ~hostname ~address)

let insert_transaction (t : Drake.Transaction.t) =
  let sender, recipient, amount, timestamp, key, signature =
    Drake.Transaction.unpack_the_transaction t
  in
  dispatch
    (Query.insert_transaction ~sender ~recipient ~amount ~timestamp ~key
       ~signature)
