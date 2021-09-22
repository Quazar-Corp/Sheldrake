open Transaction

module Drakepool : Mempool = struct
  
  type t = Transaction.t list

end
