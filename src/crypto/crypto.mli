open Mirage_crypto_pk

(* Convert a Mirage_crypto_pk.DSA key type into a string *)
val priv_to_string : Z.t * Z.t * Z.t * Z.t * Z.t -> string
val pub_to_string : Z.t * Z.t * Z.t * Z.t -> string

(* Convert a string into Mirage_crypto_pk.DSA key type *)
val priv_of_string : string -> Dsa.priv
val pub_of_string : string -> Dsa.pub

(* Generate a fresh pair of keys -> encoded in base64 from their Sexpr *)
val generate_keys : unit -> string * string

(* Retrieve the public key from the private key *)
val pub_of_priv : string -> string

(* Sign the message and returns the signature -> Base64 encoded (r + " " + s) *)
val sign : message:string -> key:string -> string

(* Verify the signature using the public key *)
val verify_signature : signature:string -> key:string -> message:string -> bool
