open Mirage_crypto_pk

let priv_to_string (p, q, gg, x, y) =  
  let key_str = (Z.to_string p) ^ "-" ^
                (Z.to_string q) ^ "-" ^
                (Z.to_string gg) ^ "-" ^
                (Z.to_string x) ^ "-" ^
                (Z.to_string y) 
  in
  Base64.encode_string key_str 

let pub_to_string (p, q, gg, y) =
  let key_str = (Z.to_string p) ^ "-" ^
                (Z.to_string q) ^ "-" ^
                (Z.to_string gg) ^ "-" ^
                (Z.to_string y) 
  in
  Base64.encode_string key_str 

let priv_of_string str =
  let decoded_str = Base64.decode_exn str
  in
  let splitted_str = String.split_on_char '-' decoded_str
  in
  let p = List.nth splitted_str 0
  in
  let q = List.nth splitted_str 1
  in
  let gg = List.nth splitted_str 2
  in
  let x = List.nth splitted_str 3
  in
  let y = List.nth splitted_str 4
  in
  let gen = Dsa.priv ~p:(Z.of_string p) 
                     ~q:(Z.of_string q) 
                     ~gg:(Z.of_string gg) 
                     ~x:(Z.of_string x) 
                     ~y:(Z.of_string y) () 
  in
  match gen with
  | Ok key -> key
  | Error _ -> raise (Invalid_argument "Error on generation: private key")

let pub_of_string str =
  let decoded_str = Base64.decode_exn str
  in
  let splitted_str = String.split_on_char '-' decoded_str
  in
  let p = List.nth splitted_str 0
  in
  let q = List.nth splitted_str 1
  in
  let gg = List.nth splitted_str 2
  in
  let y = List.nth splitted_str 3
  in
  let gen = Dsa.pub ~p:(Z.of_string p) 
                    ~q:(Z.of_string q) 
                    ~gg:(Z.of_string gg) 
                    ~y:(Z.of_string y) ()
  in 
  match gen with
  | Ok key -> key
  | Error _ -> raise (Invalid_argument "Error on generation: public key")

let generate_keys () =
  let priv_key = Dsa.generate `Fips1024
  in
  let pub_key = Dsa.pub_of_priv priv_key 
  in
  (pub_to_string (pub_key.p, pub_key.q, pub_key.gg, pub_key.y), 
   priv_to_string (priv_key.p, priv_key.q, priv_key.gg, priv_key.x, priv_key.y))

let pub_of_priv key =
  priv_of_string key |> Dsa.pub_of_priv |> fun pub_key -> pub_to_string (pub_key.p,
                                                                         pub_key.q,
                                                                         pub_key.gg,
                                                                         pub_key.y)

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
