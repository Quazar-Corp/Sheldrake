open Opium
    
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


(* App *)
let _ = 
  App.empty
  |> App.get "/blockchain/mine" mine_block
  |> App.get "/blockchain/chain" read_chain
  |> App.run_command 


