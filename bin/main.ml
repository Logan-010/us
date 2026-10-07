open Cli

let split_addr addr =
  try
    let i = String.rindex addr ':' in
    let host =
      if String.length addr > 0 && addr.[0] = '[' then (
        if i < 3 || addr.[i - 1] <> ']' then invalid_arg "Invalid host";
        String.sub addr 1 (i - 2))
      else String.sub addr 0 i
    in
    if host = "" then invalid_arg "Invalid host";
    let port =
      int_of_string (String.sub addr (i + 1) (String.length addr - i - 1))
    in
    if port < 0 || port > 65535 then invalid_arg "Invalid port";
    (host, port)
  with Not_found | Failure _ | Invalid_argument _ ->
    invalid_arg ("Invalid address: " ^ addr)

let main () =
  if args.version then (
    print_endline version_string;
    exit 0);
  if args.delete then (
    let db = Db.init args.database_path in
    Fun.protect
      ~finally:(fun () -> Dokeysto.Db.RW.close db)
      (fun () -> Db.cleanup db);
    exit 0);

  let secret =
    match args.secret with
    | Some secret when secret <> "" -> secret
    | _ -> invalid_arg "--secret is required and must not be empty"
  in
  let addr, port = split_addr args.listen_addr in
  let db = Db.init args.database_path in
  Fun.protect
    ~finally:(fun () -> Dokeysto.Db.RW.close db)
    (fun () ->
      Dream.run ~interface:addr ~port ~tls:args.tls
        ~certificate_file:args.cert_path ~key_file:args.key_path
      @@ Dream.router @@ Http.routes db secret)

let () =
  try main ()
  with Invalid_argument message ->
    prerr_endline ("us: " ^ message);
    exit 2
