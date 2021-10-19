open Block
open Sheldrake

(* Migrations-related helper functions. *)
val migrate : (module Rapper_helper.CONNECTION) -> (unit, [> Caqti_error.call_or_retrieve ]) result Lwt.t
(* Reference is the documentation *)
(* val rollback : unit -> (unit, error) result Lwt.t *)

(* Core functions *)
val get_chain : unit -> Sheldrake.t list Lwt.t
val insert_block : Drakeblock.t -> unit Lwt.t

(*val remove : int -> (unit, error) result Lwt.t
val clear : unit -> (unit, error) result Lwt.t*)
