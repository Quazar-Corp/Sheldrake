
(* SETUP *)
(**************************************************************************************************)

exception Query_failed of string

(* Postgres port address *)
let connection_url = "postgresql://localhost:5432";;

(* Our custom error *)
type error =
  | Database_error of string

(* This is the connection pool we will use for executing DB operations. *)
let pool =
  (* Result patern (type t, err) *)
  match Caqti_lwt.connect_pool ~max_size:10 (Uri.of_string connection_url) with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

(* Helper method to map Caqti errors to our own error type. 
   val data_or_error : ('a, [> Caqti_error.t ]) result Lwt.t -> ('a, error) result Lwt.t *)
(*
let data_or_error m =
  match%lwt m with
  | Ok a -> Ok a |> Lwt.return
  | Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return
*)

type stored_user = {id : string; name : string; username : string; email : string; password: string}
(**************************************************************************************************)

(* Queries *)

(* Generic exec function *)
let dispatch func =
  let open Lwt.Syntax in
  let* request_result = Caqti_lwt.Pool.use func pool in
  match request_result with
  | Ok data -> Lwt.return data
  | Error err -> Lwt.fail (Query_failed (Caqti_error.show err))

(* Create table request *)

(* Without rapper
let migrate_query =
  Caqti_request.exec
    Caqti_type.unit
    {| CREATE TABLE users (
          id SERIAL NOT NULL PRIMARY KEY,
          name VARCHAR,
          username VARCHAR,
          email VARCHAR,
          password VARCHAR
       )
    |}
   *)

let migrate =
  [%rapper
    execute
    {sql| CREATE TABLE IF NOT EXISTS users (
          id SERIAL NOT NULL PRIMARY KEY,
          name VARCHAR,
          username VARCHAR,
          email VARCHAR,
          password VARCHAR
       )
    |sql}]
    ()

(* Exec migration *)
let () = dispatch migrate |> Lwt_main.run

(*
let migrate () =
  let query = migrate_query
  in
  let migrate' (module C : Rapper_helper.CONNECTION) =
    match query with
    | Ok q -> C.exec q
    | Error err -> Lwt.fail (Query_failed (Caqti_error.show err))
  in
  Caqti_lwt.Pool.use migrate' pool |> data_or_error
*)

(* Drop table request*)
(*
let rollback_query =
  Caqti_request.exec
    Caqti_type.unit
    "DROP TABLE users"
(* Exec dropping *)
let rollback () =
  let rollback' (module C : Rapper_helper.CONNECTION) =
    C.exec rollback_query ()
  in
  Caqti_lwt.Pool.use rollback' pool |> data_or_error
*)


(* get_all query *)
(*************************************************************************************************)
(* Without rapper
let get_all_query = 
  Caqti_request.collect
    Caqti_type.unit 
    Caqti_type.(tup5 int string string string string )
    "SELECT * FROM users"
   *)

let get_all () = 
 let read_all =
    [%rapper
      get_many
        {sql|
          SELECT @string{id}, @string{name}, @string{username}, @string{email}, @string{password}
          FROM users
        |sql}
        record_out]
      ()
 in
 let open Lwt.Syntax 
 in
 let* users_list = dispatch read_all
 in
 users_list 
 |> List.map (fun {name; username; email; password; _ } -> {UserJson.name; username; email; password})
 |> Lwt.return
(*************************************************************************************************)

(* add query *)
(*************************************************************************************************)
(*
let add_query =
  Caqti_request.exec
    Caqti_type.tup5
    "INSERT INTO users (user) VALUES (?)"
let add user = 
  let add' user (module C : Caqti_lwt.CONNECTION) =
    C.exec add_query user
  in
  Caqti_lwt.Pool.use (add' user) pool |> or_error (* Pipe the result pattern *)
*)

let add ({name; username; email; password} : UserJson.t) =
  let insert =
    [%rapper
      execute
        {sql|
          INSERT INTO users
          VALUES(%string{id}, %string{name}, %string{username}, %string{email}, %string{email}, %string{password})
        |sql}
        record_in]
  in
  let id = Uuidm.create `V4 |> Uuidm.to_string in
  dispatch (insert {id; name; username; email; password})
(*************************************************************************************************)

(*let remove _id = failwith "Not implemented"
let clear () = failwith "Not implemented"*)
