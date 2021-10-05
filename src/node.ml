type address = {
  hostname : string;
  address : string;
}[@@deriving yojson]

type t = address list

(* External function to retrieve ip address with global scope *)
external get_global_addr : string = "ocaml_get_global_addr"

(* Add a new node to the network *)
let add_node address nodes =
  address :: nodes |> fun _ -> address

let retrieve_host_hostname =
  Unix.gethostname ()
