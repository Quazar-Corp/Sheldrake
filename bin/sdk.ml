open Drake
open Opium

(* Current node info *)
let this_node = Node.retrieve_host_entries
    
(* GET mine_block *)
let mine_block req =
  let open Lwt.Syntax 
  in
  let* chain = Storage.get_chain ()
  in
  let new_block = 
    Sheldrake.mine_block chain [(Transaction.create "Cleveland" "Lakers" 54000000.)]
  in
  Storage.insert_block new_block 
  |> fun _ -> req 
  |> fun _req -> Response.of_json (`Assoc ["message", `String "Successful mined!";
                                           "length", `Int ((Sheldrake.length chain)+1)])
  |> Response.set_status `Created
  |> Lwt.return
  
(* GET get_chain *)
let read_chain req =
  let open Lwt.Syntax 
  in
  let* chain = Storage.get_chain ()
  in
  let json = Sheldrake.to_yojson chain
  in
  let response = Response.of_json json
  in
  req |> fun _req -> Lwt.return response

(* GET get_mempool *)
let read_mempool req =
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
  let open Lwt.Syntax in
  let* json = Request.to_json_exn req in
  let response =
    match Transaction.of_yojson json with
    | Ok tx -> tx |> Storage.insert_transaction |> fun _ -> Response.of_json (Transaction.to_yojson tx)
    | Error err -> err |> fun _ -> Response.of_json (`Assoc ["message", `String "Verify the syntax and the name of fields!"])
                       |> Response.set_status `Bad_request 
  in
  Lwt.return response


(* App *)
let _ = 
  App.empty
  |> App.host (Node.addr this_node)
  |> App.port 4444
  |> App.get "/blockchain/mine" mine_block
  |> App.get "/blockchain/chain" read_chain
  |> App.get "/blockchain/mempool" read_mempool
  |> App.post "/blockchain/transaction" add_transaction
  |> App.run_command


