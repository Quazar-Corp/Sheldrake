type t

val add_transaction : sender:string -> receiver:string -> amount:float -> mempool:t -> Transaction.t
