(*open Mirage_crypto_pk*)

type private_key

type public_key

val generate_private_key : unit -> private_key

val generate_public_key : private_key -> public_key
