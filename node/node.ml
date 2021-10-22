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

let get_address_list network =
  let rec aux acc = function
    | [] -> ()
    | hd :: tl -> aux ((addr hd) :: acc) tl 
  in
  aux [] network
