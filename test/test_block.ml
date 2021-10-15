open Transaction
open Block
open Alcotest

(* ARRANGE *)

let mocked_chain = `Assoc [
                            ("block_index", `Int 0;
                            "timestamp", `String "0000000";
                            "nonce", `Int 000000000;
                            "transactions", `List [(Transaction.create "Cavaliers" "Lakers" 54000000.)];
                            "prev_hash", `String "0000000000000000000000000000000000000000000000000000000000000000";
                            "hash", `String "883e47459066d508517b2ad662e44f6547aa48ee7c87463ea17b826246701fd0");
                            ("block_index", `Int 1;
                            "timestamp", `String "1633706338.";
                            "nonce", `Int 1422059064;
                            "transactions", `List [(Transaction.create "Golden State Warriors" "Nets" 54000000.)];
                            "prev_hash", `String "883e47459066d508517b2ad662e44f6547aa48ee7c87463ea17b826246701fd0";
                            "hash", `String "7a59e1e463d9e219a8091f904e077bc1fbaad005b129ed23c22fa2570cc1be0d")
                          ];;


(* ACT *)


