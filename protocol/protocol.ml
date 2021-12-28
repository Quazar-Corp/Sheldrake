open Database

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
                      |> fun () -> let* req = (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string network_string))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ())  "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/node")))
                                   in
                                   req
                      |> fun (resp, body) -> resp |> fun _ -> Cohttp_lwt.Body.drain_body body 
                      |> fun _ -> aux tl
  in
  aux (Node.extract_list updated_network)

let update_chain_on_network current_node =
  let open Lwt.Syntax 
  in
  let* nodes = Storage.get_network ()
  in
  let* updated_chain = Storage.get_chain () 
  in
  let client_addr = Node.addr current_node 
  in
  let rec aux ls =
    match ls with
    | [] -> Lwt.return_unit 
    | hd :: tl -> if hd = current_node then aux tl
                  else Printf.printf 
                      "Sending request to update chain to http://%s:8333/blockchain/block%!\n" 
                      (Node.addr hd)
                      |> fun () -> let* req = (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string (Yojson.Safe.pretty_to_string (Chain.to_yojson updated_chain))))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ())  "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/block")))
                                   in
                                   req
                      |> fun (resp, body) -> resp |> fun _ -> Cohttp_lwt.Body.drain_body body 
                      |> fun _ -> aux tl
  in
  aux (Node.extract_list nodes) 

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
                      "Sending request to update mempool to http://%s:8333/blockchain/update\n%!" 
                      (Node.addr hd)
                      |> fun () -> let* req = (Cohttp_lwt_unix.Client.post
                                   ?body:(Option.some (Cohttp_lwt.Body.of_string mempool_string))
                                   ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ()) "Client" client_addr))
                                   (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/update")))
                                   in
                                   req
                      |> fun (resp, body) -> resp |> fun _ -> Cohttp_lwt.Body.drain_body body 
                      |> fun _ -> aux tl
  in
  aux (Node.extract_list nodes)

let consensus_update_chain current_node to_verify =
  let open Lwt.Syntax
  in
  let* nodes = Storage.get_network ()
  in
  let client_addr = Node.addr current_node
  in
  let rec aux count = function
    | [] -> if count >= ((List.length (Node.extract_list nodes)))/2 then Lwt.return_true else Lwt.return_false
    | hd :: tl -> if hd = current_node then aux (count+1) tl
                  else Printf.printf 
                       "Sending request to verify the update on chain in http://%s:8333/blockchain/chain\n%!"
                       (Node.addr hd)
                       |> fun () -> let* req = (Cohttp_lwt_unix.Client.get
                                    ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ()) "Client" client_addr))
                                    (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/chain")))
                                    in
                                    req
                       |> fun (resp, body) -> resp |> fun _ -> let* str_body = Cohttp_lwt.Body.to_string body in Chain.of_yojson (Yojson.Safe.from_string str_body)
                       |> fun ls -> if (Chain.length ls) = (Chain.length to_verify) && (Chain.is_valid ls) then aux (count+1) tl else aux count tl
  in
  aux 0 (Node.extract_list nodes)

let consensus_update_nodes current_node to_verify =
  let open Lwt.Syntax
  in
  let* nodes = Storage.get_network ()
  in
  let client_addr = Node.addr current_node
  in
  let rec aux count = function
    | [] -> if count >= ((List.length (Node.extract_list nodes)))/2 then Lwt.return_true else Lwt.return_false
    | hd :: tl -> if hd = current_node then aux (count+1) tl
                  else Printf.printf 
                       "Sending request to verify the update on nodes in http://%s:8333/blockchain/network\n%!"
                       (Node.addr hd)
                       |> fun () -> let* req = (Cohttp_lwt_unix.Client.get
                                    ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ()) "Client" client_addr))
                                    (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/network")))
                                    in
                                    req
                       |> fun (resp, body) -> resp |> fun _ -> let* str_body = Cohttp_lwt.Body.to_string body in Node.of_yojson (Yojson.Safe.from_string str_body)
                       |> fun ls -> if (Node.length ls) = (Node.length to_verify) then aux (count+1) tl else aux count tl
  in
  aux 0 (Node.extract_list nodes)


let consensus_update_mempool current_node to_verify =
  let open Lwt.Syntax
  in
  let* nodes = Storage.get_network ()
  in
  let client_addr = Node.addr current_node
  in
  let rec aux count = function
    | [] -> if count >= ((List.length (Node.extract_list nodes)))/2 then Lwt.return_true else Lwt.return_false
    | hd :: tl -> if hd = current_node then aux (count+1) tl
                  else Printf.printf 
                       "Sending request to verify the update on mempool in http://%s:8333/blockchain/mempool\n%!"
                       (Node.addr hd)
                       |> fun () -> let* req = (Cohttp_lwt_unix.Client.get
                                    ?headers:(Option.some (Cohttp.Header.add (Cohttp.Header.init ()) "Client" client_addr))
                                    (Uri.of_string ("http://" ^ (Node.addr hd) ^ ":8333/blockchain/mempool")))
                                    in
                                    req
                       |> fun (resp, body) -> resp |> fun _ -> let* str_body = Cohttp_lwt.Body.to_string body in Mempool.of_yojson (Yojson.Safe.from_string str_body)
                       |> fun ls -> if (Mempool.length ls) = (Mempool.length to_verify) && (Mempool.is_valid ls) then aux (count+1) tl else aux count tl
  in
  aux 0 (Node.extract_list nodes)
