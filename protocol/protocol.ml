open Database
open Drake

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
                  else Printf.printf 
                      "Sending request to update nodes to http://%s:8333/blockchain/node%!\n" 
                      (Node.addr hd) 
                      |> fun () -> (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string network_string))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ())  "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/node")))
                      |> fun _ -> aux tl
  in
  aux (Node.extract_type updated_network)

let update_chain_on_network current_node =
  let open Lwt.Syntax 
  in
  let* nodes = Storage.get_network ()
  in
  let* updated_chain = Storage.get_chain ()
  in
  let chain_string = Yojson.Safe.pretty_to_string (Chain.to_yojson updated_chain)
  in
  let client_addr = Node.addr current_node
  in
  let rec aux = function
    | [] -> Lwt.return_unit 
    | hd :: tl -> if hd = current_node then aux tl
                  else Printf.printf 
                      "Sending request to update chain to http://%s:8333/blockchain/block%!\n" 
                      (Node.addr hd)
                      |> fun () -> (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string chain_string))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ())  "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/block")))
                      |> fun _ -> aux tl
  in
  aux (Node.extract_type nodes)

let update_mempool_on_network current_node =
  let open Lwt.Syntax
  in
  let* nodes = Storage.get_network ()
  in
  let* updated_mempool = Storage.get_mempool ()
  in
  let mempool_string = Yojson.Safe.pretty_to_string (Mempool.to_yojson updated_mempool)
  in
  let client_addr = Node.addr current_node
  in
  let rec aux = function
    | [] -> Lwt.return_unit 
    | hd :: tl -> if hd = current_node then aux tl
                  else Printf.printf 
                      "Sending request to update mempool to http://%s:8333/blockchain/update%!\n" 
                      (Node.addr hd)
                      |> fun () -> (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string mempool_string))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ())  "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/update")))
                      |> fun _ -> aux tl
  in
  aux (Node.extract_type nodes)
 
