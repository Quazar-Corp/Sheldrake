open Sheldrake

(* I'm lazy to use a real db here so will be a simple file*)
let db = "database_blockchain.json";;

(* READ chain *)
let get_chain () =
  Lwt_io.with_file ~mode:Input db (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Sheldrake.of_yojson db_json))

(* CREATE block *)
let insert_block block =
  let open Lwt.Syntax in
  let* chain = get_chain () 
  in
  let updated_chain = Sheldrake.add_block block chain
  in
  Lwt_io.with_file ~mode:Output db (fun output_channel ->
      let chain_string =
        updated_chain |> Sheldrake.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel chain_string);
