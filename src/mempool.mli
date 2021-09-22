open Transaction

module type Mempool = sig 

  type t

  val sort : t -> t

  val get_sample : t -> int -> Transaction.t list

end 
