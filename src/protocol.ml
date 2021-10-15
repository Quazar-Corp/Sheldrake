let get_address_list network =
  let rec aux acc ls = function
    | [] -> ()
    | hd :: tl -> aux ((Node.addr hd) :: acc) tl 
  in
  aux [] network

let update_nodes_on_network addr_list =
  addr_list |> fun _ -> ()

let update_chain_on_network chain =
  chain |> fun _ -> ()

let update_mempool_on_network mempool =
  mempool |> fun _ -> ()
