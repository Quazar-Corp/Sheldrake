open Drake
open Database
open Opium

(* Current node info *)
let this_node = Node.retrieve_host_entries    

(* GET mine_block *)
let mine_block req =
  Logs.info ~func_name:"mine_block" ~request:req ~req_type:"GET" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* chain = Storage.get_chain ()
  in
  let* mempool = Storage.get_mempool ()
  in
  let new_block = 
    Chain.mine_block chain (Mempool.five_transactions mempool) 
  in
  Storage.insert_block new_block
  |> fun _ -> Protocol.update_chain_on_network this_node
  |> fun _ -> req 
  |> fun _req -> Response.of_json (`Assoc ["message", `String "Successful mined!";
                                           "length", `Int ((Chain.length chain)+1)])
  |> Response.set_status `Created
  |> Lwt.return

(* POST add_block *)
let add_block req =
  Logs.info ~func_name:"add_block" ~request:req ~req_type:"POST" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* json = Request.to_json_exn req 
  in
  let updated = Chain.of_yojson json
  in
  let* flag = Protocol.consensus_update_chain this_node updated 
  in
  let response = if flag then Storage.replace_chain updated |> fun _ -> Response.of_json json
                              |> Response.set_status `Created
                 else Response.of_json (`Assoc ["message", `String "Not accepted"])
                      |> Response.set_status `Not_acceptable
  in
  Lwt.return response 
  
(* GET get_chain *)
let read_chain req =
  Logs.info ~func_name:"read_chain" ~request:req ~req_type:"GET" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* chain = Storage.get_chain ()
  in
  let json = Chain.to_yojson chain
  in
  let response = Response.of_json json
  in
  req |> fun _req -> Lwt.return response

(* GET get_mempool *)
let read_mempool req =
  Logs.info ~func_name:"read_mempool" ~request:req ~req_type:"GET" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* mempool = Storage.get_mempool ()
  in
  let json = Mempool.to_yojson mempool
  in
  let response = Response.of_json json
  in
  req |> fun _req -> Lwt.return response

(* POST add_transaction *)
let add_transaction req =
  Logs.info ~func_name:"add_transaction" ~request:req ~req_type:"POST" ~time:(Unix.time ()); 
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let response =
    match Transaction.of_yojson json with
    | Ok tx -> Storage.insert_transaction tx
                  |> fun _ -> Protocol.update_mempool_on_network this_node
                  |> fun _ -> Response.of_json (Transaction.to_yojson tx)
                  |> Response.set_status `Created
    | Error err -> err |> fun _ -> Response.of_json (`Assoc ["message", `String "Verify the syntax and the name of fields!"])
                       |> Response.set_status `Bad_request 
  in
  Lwt.return response

(* POST update_mempool *)
let update_mempool req =
  Logs.info ~func_name:"update_mempool" ~request:req ~req_type:"POST" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* json = Request.to_json_exn req 
  in
  let updated = Mempool.of_yojson json
  in
  let* flag = Protocol.consensus_update_mempool this_node updated 
  in
  let response = if flag then Storage.replace_mempool updated |> fun _ -> Response.of_json json
                              |> Response.set_status `Created
                 else Response.of_json (`Assoc ["message", `String "Not accepted"])
                      |> Response.set_status `Not_acceptable
  in
  Lwt.return response 

(* GET get_network *)
let read_network req =
  Logs.info ~func_name:"read_network" ~request:req ~req_type:"GET" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* network = Storage.get_network ()
  in
  let json = Node.to_yojson network
  in
  let response = Response.of_json json
  in
  req |> fun _req -> Lwt.return response

(* POST add_node *)
let add_node req =
  Logs.info ~func_name:"add_node" ~request:req ~req_type:"POST" ~time:(Unix.time ()); 
  let open Lwt.Syntax 
  in
  let* json = Request.to_json_exn req 
  in
  let updated = Node.of_yojson json
  in
  let* flag = Protocol.consensus_update_nodes this_node updated 
  in
  let response = if flag then Storage.replace_network updated |> fun _ -> Response.of_json json
                              |> Response.set_status `Created
                 else Response.of_json (`Assoc ["message", `String "Not accepted"])
                      |> Response.set_status `Not_acceptable
  in
  Lwt.return response 

(* Setting the new node on network *)
let start_node () =
  if not (Node.check_current_node_on_network (Lwt_main.run (Storage.get_network ())) this_node) 
  then Protocol.update_nodes_on_network this_node
  else Lwt.return_unit

(* App *)
let _ =
  Lwt_main.run (start_node ())
  |> fun () -> App.empty
  |> App.host (Node.addr this_node)
  |> App.port 8333
  |> App.get "/blockchain/mine" mine_block
  |> App.post "/blockchain/block" add_block
  |> App.get "/blockchain/chain" read_chain
  |> App.get "/blockchain/mempool" read_mempool
  |> App.post "/blockchain/transaction" add_transaction
  |> App.post "/blockchain/update" update_mempool
  |> App.post "/blockchain/node" add_node
  |> App.get "/blockchain/network" read_network
  |> App.run_command 


