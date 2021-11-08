(*
open Drake
open Alcotest

(* ARRANGE *)

let block_1 = Block.create 
                ~nonce:000000000
                ~transactions:[(Transaction.create "Cavaliers" "Lakers" 54000000.)]
                ~prev_hash:"0000000000000000000000000000000000000000000000000000000000000000"

let block_2 = Block.create 
                ~nonce:(Block.get_nonce block_1)
                ~transactions:[(Transaction.create "Golden State Warriors" "Nets" 54000000.)]
                ~prev_hash:(Block.get_hash block_1)

let block_3 = Block.create 
                ~nonce:(Block.get_nonce block_2)
                ~transactions:[(Transaction.create "Pelicans" "Bulls" 54000000.)]
                ~prev_hash:(Block.get_hash block_2)

let mocked_chain = [block_1; block_2; block_3]

let mocked_json = [%to_yojson: Block.t list] mocked_chain

(* ACT *)

let test_json_to_block_list () =
  (check bool) "JSON Encode" true (Yojson.Safe.equal
                                     mocked_json
                                     (Block.list_to_yojson mocked_chain))

let test_block_list_to_json () =
  (check bool) "JSON Decode" true (List.equal
                                     (fun a b -> if a = b then true else false)
                                     mocked_chain
                                     (Block.list_of_yojson mocked_json))

(* ASSERT *)
let () =
  run "Block" [
      "JSON Convert", [
          test_case "Chain to JSON" `Quick test_json_to_block_list;
          test_case "JSON to Chain" `Quick test_block_list_to_json;
        ];
    ]
*)
