open Drake

val get_chain : unit -> Sheldrake.t Lwt.t

val insert_block : Block.t -> unit Lwt.t
