(* Transaction type *)
(* Serializable record *) 
type t = {
  from_ : string;
  to_ : string;
  amount : float;
}[@@deriving yojson {exn = true}] (* I don't know if that is a good idea *)

(* Transaction to json *)
let to_yojson tx =
  [%to_yojson: t] tx

let of_yojson json =
  match [%of_yojson: t] json with
  | Ok tx -> tx
  | Error err -> err |> fun _ -> raise Parsing.Parse_error

let to_string tx =
  tx.from_ ^ tx.to_ ^ (Float.to_string tx.amount)

let create from_ to_ amount =
  {from_=from_; to_=to_; amount=amount}

