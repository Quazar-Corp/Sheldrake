open Block
open Sheldrake

val get_chain : unit -> Sheldrake.t Lwt.t

val insert_block : Drakeblock.t -> unit Lwt.t
