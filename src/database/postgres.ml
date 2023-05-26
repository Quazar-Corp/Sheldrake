open Drake

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
  | Ok data -> Caqti_lwt.Pool.drain pool |> fun _ -> Lwt.return data
  | Error error -> Lwt.fail (Query_failed (Caqti_error.show error))
(* ********************************************************************************************* *)

(* Running migrations *)
(* ********************************************************************************************* *)
(* Running *)
let migrate () =
  Printf.printf ">>> Migrating the database\n";
  dispatch Query.ensure_table_chain_exists |> Lwt_main.run |> fun () ->
  dispatch Query.ensure_table_mempool_exists |> Lwt_main.run |> fun () ->
  dispatch Query.ensure_table_network_exists |> Lwt_main.run
(* ********************************************************************************************* *)

(* Queries *)
(* ********************************************************************************************* *)
let get_network () = dispatch Query.read_network

let update_network (node : Node.t) =
  let hostname, address = Node.unpack_the_node node in
  dispatch (Query.update_network ~hostname ~address)

let insert_transaction (t : Transaction.t) =
  let sender, recipient, amount, timestamp, key, signature =
    Transaction.unpack_the_transaction t
  in
  dispatch
    (Query.insert_transaction ~sender ~recipient ~amount ~timestamp ~key
       ~signature)

let get_mempool () = dispatch Query.read_mempool

let insert_block b =
  let index, timestamp, nonce, merkle_root, transactions, prev_hash, hash =
    Block.unpack_the_block b
  in
  let json_str_txns =
    transactions |> Transaction.to_yojson_list |> Yojson.Safe.pretty_to_string
  in
  dispatch
    (Query.insert_block ~index ~timestamp ~nonce ~merkle_root
       ~transactions:json_str_txns ~prev_hash ~hash)

let get_chain () = dispatch Query.read_chain
