(* Transaction type *)
(* Serializable record *) 
(* Fees are used in every transaction? *)
module Transaction : Tx = struct   
  type t = {
    from_ : string;
    to_ : string;
    amount : float;
    fee : float
  }[@@deriving yojson]

  let to_string tx =
    tx.from_ ^ tx.to_ ^ (Float.to_string tx.amount) ^ (Float.to_string tx.fee)

  let to_yojson tx =
    [%to_yojson: Transaction.t] tx

  let of_yojson json =
    [%of_yojson: Transaction.t] json
end

(*************************************************************************************************)

(* Transaction list with signature *)
module ScriptSig : TxList = struct 

  type t = {
    ledger : Transaction.t list;
    signature : string
  }[@@deriving yojson]

end
