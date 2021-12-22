open Mirage_crypto_pk

let priv_of_string str =
  let sexpr = Sexplib0.Sexp_conv.sexp_of_string str
  in
  Dsa.priv_of_sexp sexpr 

let pub_of_string str =
  let sexpr = Sexplib0.Sexp_conv.sexp_of_string str
  in
  Dsa.pub_of_sexp sexpr

let priv_to_string key =
  let sexp = Dsa.sexp_of_priv key
  in
  Sexplib0.Sexp.to_string sexp

let pub_to_string key =
  let sexp = Dsa.sexp_of_pub key
  in
  Sexplib0.Sexp.to_string sexp

let generate_keys () =
  let priv_key = Dsa.generate `Fips1024
  in
  let pub_key = Dsa.pub_of_priv priv_key 
  in
  (pub_to_string pub_key, priv_to_string priv_key)

let sign ~message ~key =
  Dsa.sign ~key:(priv_of_string key) (Cstruct.of_string message) 
  |> fun (r, s) -> (Cstruct.to_string r) ^ " " ^ (Cstruct.to_string s)
  |> fun signature -> Base64.encode_string signature

let verify_signature ~signature ~key ~message =
  let decoded_signature =
    Base64.decode_exn signature
    |> String.split_on_char ' '
    |> fun rs -> (Cstruct.of_string (List.hd rs), Cstruct.of_string (List.hd (List.rev rs)))
  in
  Dsa.verify ~key:(pub_of_string key) decoded_signature (Cstruct.of_string message)
