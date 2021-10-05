type t = Transaction.t list

(* Create transaction *)
let add_transaction ~sender ~receiver ~amount ~mempool =
  Transaction.create sender receiver amount
  |> fun tx -> tx :: mempool
  |> fun _ -> (List.hd mempool)
