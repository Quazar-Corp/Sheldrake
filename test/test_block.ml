open Drake
open Alcotest

(* ARRANGE *)

let block_1 = Block.create 
                ~nonce:000000000
                ~transactions:[(Transaction.create "Cavaliers" "Lakers" 54000000.)]
                ~prev_hash:"0000000000000000000000000000000000000000000000000000000000000000"

let block_1_hash = let block_str = Block.to_string block_1
                   in
                   Block.update_hash block_1 (Sha256.to_hex (Sha256.string block_str)) 
                   |> fun () -> Block.get_hash block_1

let block_2 = Block.create 
                ~nonce:(Block.get_nonce block_1)
                ~transactions:[(Transaction.create "Golden State Warriors" "Nets" 54000000.)]
                ~prev_hash:(Block.get_hash block_1)

let block_3 = Block.create 
                ~nonce:(Block.get_nonce block_2)
                ~transactions:[(Transaction.create "Pelicans" "Bulls" 54000000.)]
                ~prev_hash:(Block.get_hash block_2)

(* ACT *)
(* Jsonfy test  *)
let test_json_to_block () =
  (check bool) "JSON Encode" true (Yojson.Safe.equal
                                     ([%to_yojson: Block.t] block_1)
                                     (Block.to_yojson block_1))

let test_block_to_json () =
  (check int) "JSON Decode" 0 (String.compare 
                                     (Block.get_hash (match [%of_yojson: Block.t] ([%to_yojson: Block.t] block_2) with
                                                        | Ok block -> block
                                                        | Error err -> err |> raise Parsing.Parse_error))
                                     (Block.get_hash (match Block.of_yojson ([%to_yojson: Block.t] block_2) with
                                                        | Ok block -> block
                                                        | Error err -> err |> raise Parsing.Parse_error)))
(* Retrieve hash test *)
let test_get_hash () =
  (check string) "Retrieve Hash" block_1_hash (Block.get_hash block_1)

(* Update hash test *)
let test_update_hash () =
  (check int) "Update Hash" 1 (String.compare
                                 block_1_hash
                                 (Block.get_hash (Block.update_hash block_1 "123456" |> fun () -> block_1)))

(* ASSERT *)
let () =
  run "Isolated Block's test" [
      "JSON Convert", [
          test_case "JSON to Block" `Quick test_json_to_block;
          test_case "Block to JSON" `Quick test_block_to_json;
      ];
      "HASH Operations", [
          test_case "Retrieve the correct Hash" `Quick test_get_hash;
          test_case "Update Hash" `Quick test_update_hash;
      ];
    ]
