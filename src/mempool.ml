open Transaction

module Mempool : sig 

  type t

end = struct 

  type t = Transaction.t list

end
