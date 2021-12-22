(* Encoded base64 string *)
type private_key

(* Encoded base64 string *)
type public_key

val generate_keys : unit -> private_key * public_key

val sign : message:string -> key:private_key -> string

val verify_signature : signature:string -> key:public_key -> bool
