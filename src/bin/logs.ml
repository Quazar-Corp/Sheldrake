open Opium

let info ~func_name ~request ~req_type ~time =
  let client = Option.get (Request.header "client" request)
  in
  let localtime = Unix.localtime time
  in
  let log_string = 
    "[" ^ req_type ^ "] " ^ func_name ^ " | Client: " ^ client ^ " | Date: " 
    ^ (Int.to_string localtime.tm_hour) ^ ":" ^ (Int.to_string localtime.tm_min) ^ ":" 
    ^ (Int.to_string localtime.tm_sec) ^ " - " ^ (Int.to_string localtime.tm_mday) ^ "/" 
    ^ (Int.to_string (localtime.tm_mon+1)) ^ "/" ^ (Int.to_string (localtime.tm_year+1900)) ^ ";"
  in
  Printf.printf "%s\n%!" log_string 

  
