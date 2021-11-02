open Database
open Opium

let update_nodes_on_network new_node =
  Lwt_main.run (Storage.update_nodes new_node);
  let open Lwt.Syntax 
  in
  let* updated_network = Storage.get_network ()
  in
  let network_string = Yojson.Safe.pretty_to_string (Node.to_yojson updated_network)
  in
  let client_addr = Node.addr new_node
  in
  let rec aux = function
    | [] -> Lwt.return_unit
    | hd :: tl -> if hd = new_node then aux tl
                  else Request.post ?body:(Option.some (Body.of_string network_string))
                                    ?headers:(Option.some (Headers.add (Headers.empty) "Client" client_addr))
                                    ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/node")
                      |> fun _ -> aux tl
  in
  aux (Node.extract_type updated_network)

let update_chain_on_network chain =
  chain |> fun _ -> ()

let update_mempool_on_network mempool =
  mempool |> fun _ -> ()
  
