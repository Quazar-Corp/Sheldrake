let read_network =
  [%rapper
      get_many
          {sql|
              SELECT @string{hostname}, @string{address}
              FROM network;
          |sql}
          function_out]
          (fun ~hostname ~address -> Node.init hostname address)
          ()

let update_network = 
  [%rapper
    execute
        {sql|
            INSERT INTO network (hostname, address)
            VALUES (%string{hostname}, %string{address});
        |sql}
        ]

