type address = string

type t = address list

(* Add a new node to the network *)
let add_node address nodes =
  address :: nodes |> fun _ -> address

let retrieve_host_address =
  Unix.gethostname ()
