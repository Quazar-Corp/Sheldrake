(*open Drake*)

exception Query_failed of string

(* Setup of database pool *)
(* ********************************************************************************************* *)
let connection_url = "postgresql://localhost:5431/sheldrake?user=admin&password=sup3rS3cr3tP455w0rd
                      ssl=false"

(* Pool connection to the database *)
let pool =
    match Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string connection_url) with
    | Ok pool -> pool
    | Error err -> failwith (Caqti_error.show err)

(* Execute the queries *)
let dispatch func =
    let open Lwt.Syntax
    in
    let* result = Caqti_lwt.Pool.use func pool 
    in
    match result with
    | Ok data -> Lwt.return data
    | Error error -> Lwt.fail (Query_failed (Caqti_error.show error))
(* ********************************************************************************************* *)


(* Running migrations *)
(* ********************************************************************************************* *)
(* CLIENT TABLE *)
let ensure_table_blocks_exists =
    [%rapper 
        execute
            {sql|
                CREATE TABLE IF NOT EXISTS blocks (
                    id VARCHAR PRIMARY KEY NOT NULL,
                    timestamp VARCHAR NOT NULL,
                    nonce INT NOT NULL,
                    merkle_root VARCHAR NOT NULL,
                    transactions JSON NULL,
                    prev_hash VARCHAR NOT NULL,
                    hash VARCHAR NOT NULL
                );
            |sql}]
            ()

(* PERSONAL TABLE *)
let ensure_table_transactions_exists =
    [%rapper
        execute
            {sql|
                CREATE TABLE IF NOT EXISTS transactions (
                    id VARCHAR PRIMARY KEY NOT NULL,
                    sender VARCHAR NOT NULL,
                    recipient VARCHAR NOT NULL,
                    amount FLOAT NOT NULL,
                    timestamp VARCHAR NOT NULL,
                    signature VARCHAR NOT NULL
                );
            |sql}]
            ()

(* EXERCICE TABLE *)
let ensure_table_nodes_exist = 
    [%rapper
        execute
            {sql|
                CREATE TABLE IF NOT EXISTS nodes (
                    id VARCHAR PRIMARY KEY NOT NULL,
                    hostname VARCHAR NOT NULL,
                    address VARCHAR NOT NULL
                );
            |sql}]
            ()


(* Running *)
let migrate () = 
         dispatch ensure_table_blocks_exists 
         |> Lwt_main.run 
         |> fun () -> dispatch ensure_table_transactions_exists
         |> Lwt_main.run 
         |> fun () -> dispatch ensure_table_nodes_exist
         |> Lwt_main.run
(* ********************************************************************************************* *)


(*
(* READ chain *)
let get_chain () =
  Lwt_io.with_file ~mode:Input chain_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Chain.of_yojson db_json))

(* CREATE block *)
let insert_block block =
  let open Lwt.Syntax in
  let* chain = get_chain () 
  in
  let updated_chain = Chain.add_block chain block
  in
  Lwt_io.with_file ~mode:Output chain_table (fun output_channel ->
      let chain_string =
        updated_chain |> Chain.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel chain_string)

(* REPLACE Chain *)
let replace_chain chain =
  Lwt_io.with_file ~mode:Output chain_table (fun output_channel ->
      let chain_string =
        chain |> Chain.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel chain_string)

(* READ mempool *)
let get_mempool () =
  Lwt_io.with_file ~mode:Input mempool_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Mempool.of_yojson db_json))

(* CREATE Transaction *)
let insert_transaction tx =
  let open Lwt.Syntax in
  let* mempool = get_mempool () 
  in
  let updated_mempool = Mempool.add_transaction mempool tx
  in
  Lwt_io.with_file ~mode:Output mempool_table (fun output_channel ->
      let mempool_string =
        updated_mempool |> Mempool.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel mempool_string)

(* REPLACE Chain *)
let replace_mempool mempool =
  Lwt_io.with_file ~mode:Output mempool_table (fun output_channel ->
      let mempool_string =
        mempool |> Mempool.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel mempool_string)

(* READ nodes *)
let get_network () =
  Lwt_io.with_file ~mode:Input node_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Node.of_yojson db_json))

(* CREATE Node *)
let update_nodes node =
  let open Lwt.Syntax in
  let* network = get_network () 
  in
  let updated_network = Node.add_node network node
  in
  Lwt_io.with_file ~mode:Output node_table (fun output_channel ->
      let network_string =
        updated_network |> Node.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel network_string)

(* REPLACE Network *)
let replace_network network =
  Lwt_io.with_file ~mode:Output node_table (fun output_channel ->
      let network_string =
        network |> Node.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel network_string)*)
