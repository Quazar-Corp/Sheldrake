open Drake
open Database

let update_nodes_on_network new_node =
  let open Lwt.Syntax in
  let* updated_network = Postgres.get_network () in
  let network_string =
    Yojson.Safe.pretty_to_string (Node.to_yojson_list updated_network)
  in
  let client_addr = Node.addr new_node in
  let rec aux = function
    | [] -> Lwt.return_unit
    | hd :: tl ->
        if hd = new_node then aux tl
        else
          Printf.printf
            "Sending request to update nodes to http://%s:8333/blockchain/node%!\n"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.post
              ?body:(Option.some (Cohttp_lwt.Body.of_string network_string))
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/node"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          Cohttp_lwt.Body.drain_body body |> fun _ -> aux tl
  in
  aux updated_network

let update_chain_on_network current_node =
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let* updated_chain = Postgres.get_chain () in
  let client_addr = Node.addr current_node in
  let rec aux ls =
    match ls with
    | [] -> Lwt.return_unit
    | hd :: tl ->
        if hd = current_node then aux tl
        else
          Printf.printf
            "Sending request to update chain to \
             http://%s:8333/blockchain/block%!\n"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.post
              ?body:
                (Option.some
                   (Cohttp_lwt.Body.of_string
                      (Yojson.Safe.pretty_to_string
                         (Block.to_yojson_list updated_chain))))
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/block"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          Cohttp_lwt.Body.drain_body body |> fun _ -> aux tl
  in
  aux network

let update_mempool_on_network current_node =
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let* updated_mempool = Postgres.get_mempool () in
  let mempool_string =
    Yojson.Safe.pretty_to_string (Transaction.to_yojson_list updated_mempool)
  in
  let client_addr = Node.addr current_node in
  let rec aux = function
    | [] -> Lwt.return_unit
    | hd :: tl ->
        if hd = current_node then aux tl
        else
          Printf.printf
            "Sending request to update mempool to \
             http://%s:8333/blockchain/update\n\
             %!"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.post
              ?body:(Option.some (Cohttp_lwt.Body.of_string mempool_string))
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/update"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          Cohttp_lwt.Body.drain_body body |> fun _ -> aux tl
  in
  aux network

let consensus_update_chain current_node (to_verify : Block.t list) =
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let client_addr = Node.addr current_node in
  let rec aux count = function
    | [] ->
        if count >= List.length network / 2 then Lwt.return_true
        else Lwt.return_false
    | hd :: tl ->
        if hd = current_node then aux (count + 1) tl
        else
          Printf.printf
            "Sending request to verify the update on chain in \
             http://%s:8333/blockchain/chain\n\
             %!"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.get
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/chain"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          let* str_body = Cohttp_lwt.Body.to_string body in
          Block.of_yojson_list (Yojson.Safe.from_string str_body) |> fun ls ->
          if List.length ls = List.length to_verify && Block.is_valid_chain ls
          then aux (count + 1) tl
          else aux count tl
  in
  aux 0 network

let consensus_update_nodes current_node (to_verify : Node.t list) =
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let client_addr = Node.addr current_node in
  let rec aux count = function
    | [] ->
        if count >= List.length network / 2 then Lwt.return_true
        else Lwt.return_false
    | hd :: tl ->
        if hd = current_node then aux (count + 1) tl
        else
          Printf.printf
            "Sending request to verify the update on nodes in \
             http://%s:8333/blockchain/network\n\
             %!"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.get
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/network"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          let* str_body = Cohttp_lwt.Body.to_string body in
          Node.of_yojson_list (Yojson.Safe.from_string str_body) |> fun ls ->
          if List.length ls = List.length to_verify then aux (count + 1) tl
          else aux count tl
  in
  aux 0 network

let consensus_update_mempool current_node (to_verify : Transaction.t list) =
  let open Lwt.Syntax in
  let* network = Postgres.get_network () in
  let client_addr = Node.addr current_node in
  let rec aux count = function
    | [] ->
        if count >= List.length network / 2 then Lwt.return_true
        else Lwt.return_false
    | hd :: tl ->
        if hd = current_node then aux (count + 1) tl
        else
          Printf.printf
            "Sending request to verify the update on mempool in \
             http://%s:8333/blockchain/mempool\n\
             %!"
            (Node.addr hd)
          |> fun () ->
          let* req =
            Cohttp_lwt_unix.Client.get
              ?headers:
                (Option.some
                   (Cohttp.Header.add (Cohttp.Header.init ()) "Client"
                      client_addr))
              (Uri.of_string
                 ("http://" ^ Node.addr hd ^ ":8333/blockchain/mempool"))
          in
          req |> fun (resp, body) ->
          resp |> fun _ ->
          let* str_body = Cohttp_lwt.Body.to_string body in
          Transaction.of_yojson_list (Yojson.Safe.from_string str_body)
          |> fun ls ->
          if
            List.length ls = List.length to_verify
            && Transaction.is_valid_mempool ls
          then aux (count + 1) tl
          else aux count tl
  in
  aux 0 network
