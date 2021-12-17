(*open Mirage_crypto_pk*)

type private_key = string

type public_key = string

let generate_private_key () =
  "private key"

let generate_public_key privk =
  "Public key of " ^ privk
