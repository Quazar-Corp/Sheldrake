open Drake

(* Real DB in future *)
let chain_table = "tmp_database/chain_table.json"
let mempool_table = "tmp_database/mempool_table.json"
let node_table = "tmp_database/nodes_table.json"

(* READ chain *)
let get_chain () =
  Lwt_io.with_file ~mode:Input chain_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Chain.of_yojson db_json))

(* CREATE block *)
let insert_block block =
  let open Lwt.Syntax in
  let* chain = get_chain () 
  in
  let updated_chain = Chain.add_block chain block
  in
  Lwt_io.with_file ~mode:Output chain_table (fun output_channel ->
      let chain_string =
        updated_chain |> Chain.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel chain_string)

(* READ mempool *)
let get_mempool () =
  Lwt_io.with_file ~mode:Input mempool_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Mempool.of_yojson db_json))

(* CREATE Transaction *)
let insert_transaction tx =
  let open Lwt.Syntax in
  let* mempool = get_mempool () 
  in
  let updated_mempool = Mempool.add_transaction mempool tx
  in
  Lwt_io.with_file ~mode:Output mempool_table (fun output_channel ->
      let mempool_string =
        updated_mempool |> Mempool.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel mempool_string)

(* READ nodes *)
let get_network () =
  Lwt_io.with_file ~mode:Input node_table (fun input_channel ->
      let open Lwt.Syntax in
      let* db_str = Lwt_io.read_lines input_channel |> Lwt_stream.to_list
      in
      let db_json =
        Yojson.Safe.from_string (String.concat "\n" db_str)
      in 
      Lwt.return (Node.of_yojson db_json))

(* CREATE Transaction *)
let update_nodes node =
  let open Lwt.Syntax in
  let* network = get_network () 
  in
  let updated_network = Node.add_node network node
  in
  Lwt_io.with_file ~mode:Output node_table (fun output_channel ->
      let network_string =
        updated_network |> Node.to_yojson |> Yojson.Safe.pretty_to_string
      in
      Lwt_io.write output_channel network_string)
