(* Transaction type *)
(* Serializable record *)  
module Transaction : sig 

  type t

  val to_string : t -> string

end = struct   
  
  type t = {
    from_ : string;
    amount : float;
    to_ : string;
    fee : float
  }[@@deriving yojson]

  let to_string tx =
    tx.from_ ^ (Float.to_string tx.amount) ^ tx.to_
end
