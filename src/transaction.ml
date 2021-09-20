(* Transaction type *)
(* Serializable record *)  
module Transaction = struct 
  
  type t = {
    from_ : string;
    amount : float;
    to_ : string;
  }[@@deriving yojson]

  let to_string tx =
    tx.from_ ^ (Float.to_string tx.amount) ^ tx.to_
end
