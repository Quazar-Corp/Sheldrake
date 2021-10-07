type host_info = {
  hostname : string;
  address : string;
}[@@deriving yojson]

type t = host_info list

(* External function to retrieve ip address with global scope *)
external get_global_addr : unit -> string = "stub_get_global_addr"

(* Add a new node to the network *)
let add_node nodes address =
  address :: nodes |> fun _ -> address

let retrieve_host_entries =
  let host_name = Unix.gethostname () in
  let host_addr = get_global_addr () in
  (*Printf.printf "HOSTNAME: %s\nIP: %s\n" host_name host_addr*) 
  {hostname = host_name; address = host_addr}

(* Retrieve node ip *)
let addr node =
  node.address 
