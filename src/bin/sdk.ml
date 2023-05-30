open Drake
open Database
open Opium

(* Retrieve current node information *)
let current_node = Node.retrieve_host_entries

(* GET mine_block *)
let mine_block req =
  Logs.info ~func_name:"mine_block" ~request:req ~req_type:"GET"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* chain = Postgres.get_chain () in
  let* mempool = Postgres.get_mempool () in
  let new_block =
    Block.mine_block (Transaction.five_transactions mempool) chain
    (* TODO: how many and how to select the transactions in the mempool*)
  in

  Postgres.insert_block new_block |> fun _ ->
  Protocol.update_chain_on_network current_node |> fun _ ->
  req |> fun _req ->
  Response.of_json
    (`Assoc
      [
        ("message", `String "Successful mined!");
        ("length", `Int (List.length chain + 1));
      ])
  |> Response.set_status `Created
  |> Lwt.return

(* POST add_block *)
let add_block req =
  Logs.info ~func_name:"add_block" ~request:req ~req_type:"POST"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let updated = Block.of_yojson_list json in
  let* flag = Protocol.consensus_update_chain current_node updated in
  let response =
    if flag then
      Storage.replace_chain updated |> fun _ ->
      Response.of_json json |> Response.set_status `Created
    else
      Response.of_json (`Assoc [ ("message", `String "Not accepted") ])
      |> Response.set_status `Not_acceptable
  in
  Lwt.return response

(* GET get_chain *)
let read_chain req =
  Logs.info ~func_name:"read_chain" ~request:req ~req_type:"GET"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* chain = Postgres.get_chain () in
  let json = Block.to_yojson_list chain in
  let response = Response.of_json json in
  req |> fun _req -> Lwt.return response

(* GET get_mempool *)
let read_mempool req =
  Logs.info ~func_name:"read_mempool" ~request:req ~req_type:"GET"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* mempool = Postgres.get_mempool () in
  let json = Transaction.to_yojson_list mempool in
  let response = Response.of_json json in
  req |> fun _req -> Lwt.return response

(* POST add_transaction *)
let add_transaction req =
  Logs.info ~func_name:"add_transaction" ~request:req ~req_type:"POST"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let response =
    match Transaction.of_yojson json with
    | Ok tx ->
        Postgres.insert_transaction tx |> fun _ ->
        Protocol.update_mempool_on_network current_node |> fun _ ->
        Response.of_json (Transaction.to_yojson tx)
        |> Response.set_status `Created
    | Error err ->
        err |> fun _ ->
        Response.of_json
          (`Assoc
            [ ("message", `String "Verify the syntax and the name of fields!") ])
        |> Response.set_status `Bad_request
  in
  Lwt.return response

(* Mocked transaction to tests purposes *)
type m_tx = { sender : string; recipient : string; amount : float }
[@@deriving yojson]

(* POST generate_transaction *)
let generate_transaction req =
  Logs.info ~func_name:"generate_transaction" ~request:req ~req_type:"POST"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let response =
    match m_tx_of_yojson json with
    | Ok mtx ->
        Crypto.generate_keys () |> fun (_, priv) ->
        Transaction.create ~sender:mtx.sender ~recipient:mtx.recipient
          ~amount:mtx.amount ~key:priv
        |> fun tx ->
        (Postgres.insert_transaction tx, tx) |> fun (_, tx) ->
        Response.of_json (Transaction.to_yojson tx)
        |> Response.set_status `Created
    | Error _ ->
        Response.of_json
          (`Assoc [ ("message", `String "Something goes wrong...") ])
        |> Response.set_status `Bad_request
  in
  Protocol.update_mempool_on_network current_node |> fun _ ->
  Lwt.return response

(* POST update_mempool *)
let update_mempool req =
  Logs.info ~func_name:"update_mempool" ~request:req ~req_type:"POST"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let updated = Transaction.of_yojson_list json in
  let* flag = Protocol.consensus_update_mempool current_node updated in
  let response =
    if flag then
      Storage.replace_mempool updated |> fun _ ->
      Response.of_json json |> Response.set_status `Created
    else
      Response.of_json (`Assoc [ ("message", `String "Not accepted") ])
      |> Response.set_status `Not_acceptable
  in
  Lwt.return response

(* GET get_network *)
let read_network req =
  Logs.info ~func_name:"read_network" ~request:req ~req_type:"GET"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let json = Node.to_yojson_list network in
  let response = Response.of_json json in
  req |> fun _req -> Lwt.return response

(* POST add_node *)
let add_node req =
  Logs.info ~func_name:"add_node" ~request:req ~req_type:"POST"
    ~time:(Unix.time ());
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let updated = Node.of_yojson_list json in
  let* flag = Protocol.consensus_update_nodes current_node updated in
  let response =
    if flag then
      Storage.replace_network updated |> fun _ ->
      Response.of_json json |> Response.set_status `Created
    else
      Response.of_json (`Assoc [ ("message", `String "Not accepted") ])
      |> Response.set_status `Not_acceptable
  in
  Protocol.update_mempool_on_network current_node |> fun _ ->
  Lwt.return response

(* Database migrations*)
let () = Postgres.migrate ()

(* Starts crypto library*)
let () = Mirage_crypto_rng_unix.initialize ()

(* Setting the new node on network *)
let start_node () =
  if
    not
      (Node.check_current_node_on_network current_node
         (Lwt_main.run (Postgres.get_network ())))
  then
    Lwt_main.run (Postgres.update_network current_node) |> fun () ->
    Protocol.update_nodes_on_network current_node
  else Lwt.return_unit

(* App *)
let _ =
  Printf.printf ">>> Starting node...\n";
  Lwt_main.run (start_node ());
  App.empty
  |> App.host (Node.addr current_node)
  |> App.port 8333
  |> App.get "/blockchain/mine" mine_block
  |> App.post "/blockchain/block" add_block
  |> App.get "/blockchain/chain" read_chain
  |> App.get "/blockchain/mempool" read_mempool
  |> App.post "/blockchain/transaction" add_transaction
  |> App.post "/blockchain/mock_transaction" generate_transaction
  |> App.post "/blockchain/update" update_mempool
  |> App.post "/blockchain/node" add_node
  |> App.get "/blockchain/network" read_network
  |> fun app ->
  Printf.printf ">>> Starting server...\n";
  app |> App.run_multicore
