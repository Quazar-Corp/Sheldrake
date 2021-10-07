let get_address_list network =
  let rec aux acc ls = function
    | [] -> ()
    | hd :: tl -> aux ((Node.addr hd) :: acc) tl 
  in
  aux [] network

