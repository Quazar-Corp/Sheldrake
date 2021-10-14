type host_info = {
  hostname : string;
  address : string;
}[@@deriving yojson]

type t = host_info list

external get_global_addr : unit -> string = "stub_get_global_addr"

let add_node nodes address =
  address :: nodes |> fun _ -> address

let retrieve_host_entries =
  let host_name = Unix.gethostname () in
  let host_addr = get_global_addr () in
  (*Printf.printf "HOSTNAME: %s\nIP: %s\n" host_name host_addr*) 
  {hostname = host_name; address = host_addr}

let addr current_node =
  current_node.address 

let name current_node = 
  current_node.hostname 

let update_nodes_on_network addr_list =
  addr_list |> fun _ -> ()

let update_chain_on_network chain =
  chain |> fun _ -> ()

let update_mempool_on_network mempool =
  mempool |> fun _ -> ()
