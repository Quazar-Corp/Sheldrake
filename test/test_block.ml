open Drake
open Alcotest

(* ARRANGE *)

let mocked_chain = let open Block in
                    [
                    {block_index = 0;
                    timestamp = "0000000";
                    nonce = 000000000;
                    transactions = [(Transaction.create "Cavaliers" "Lakers" 54000000.)];
                    prev_hash = "0000000000000000000000000000000000000000000000000000000000000000";
                    hash = "883e47459066d508517b2ad662e44f6547aa48ee7c87463ea17b826246701fd0"
                    };
                    {block_index = 1;
                    timestamp = "1633706338.";
                    nonce = 1422059064;
                    transactions = [(Transaction.create "Golden State Warriors" "Nets" 54000000.)];
                    prev_hash = "883e47459066d508517b2ad662e44f6547aa48ee7c87463ea17b826246701fd0";
                    hash = "7a59e1e463d9e219a8091f904e077bc1fbaad005b129ed23c22fa2570cc1be0d"
                    };
                    ]


let mocked_json = [%to_yojson: Block.t list] mocked_chain


(* ACT *)

let test_json =
  (check Yojson.Safe.t) "JSON Encode" mocked_json (Block.list_to_yojson mocked_chain)

(* ASSERT *)
let () =
  run "Block" [
      "JSON Convertions", [
          test_case "Chain to JSON" `Quick test_json;
        ];
    ]
