open Cli
open Config

let split_addr addr =
  try
    let i = String.rindex addr ':' in
    let host =
      if String.length addr > 0 && addr.[0] = '[' then String.sub addr 1 (i - 2)
      else String.sub addr 0 i
    in
    let port =
      int_of_string (String.sub addr (i + 1) (String.length addr - i - 1))
    in
    if port < 0 || port > 65535 then invalid_arg "Invalid port";
    (host, port)
  with Not_found | Failure _ | Invalid_argument _ ->
    invalid_arg ("Invalid address: " ^ addr)

let () =
  if args.version then (
    print_endline version_string;
    exit 0);

  let config_path =
    match args.config with
    | Some p -> p
    | None ->
        (if Sys.os_type = "Unix" then "HOME" else "USERPROFILE") |> Sys.getenv
        |> fun d -> Filename.concat d @@ Filename.concat ".us" "config.toml"
  in

  let config =
    override_config
    @@
    if not @@ Sys.file_exists config_path then (
      (if Filename.dirname config_path |> Sys.file_exists |> not then
         let rec mkdir_all path =
           if Sys.file_exists path then
             begin if not (Sys.is_directory path) then
               failwith "Path exists but is not a directory"
             end
           else begin
             mkdir_all (Filename.dirname path);
             Sys.mkdir path 0o755
           end
         in

         mkdir_all @@ Filename.dirname config_path);

      let config_file = Out_channel.open_text config_path in
      Out_channel.output_string config_file default_config_string;
      Out_channel.flush config_file;
      Out_channel.close config_file;

      default_config)
    else
      In_channel.open_text config_path |> In_channel.input_all |> parse_config
  in

  let db = Db.init config.database_path in

  ignore db;
  
  let config = override_config config in
  let addr, port = split_addr config.listen_addr in

  Dream.run ~interface:addr ~port
    ~tls:(Option.value ~default:false config.tls)
    ~certificate_file:(Option.value ~default:"" config.cert_path)
    ~key_file:(Option.value ~default:"" config.key_path)
  @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/" (fun request ->
             Dream.log "Sending greeting to %s!" (Dream.client request);
             Dream.html "Good morning, world!");
         Dream.get "/fail" (fun _ ->
             Dream.warning (fun log -> log "Raising an exception!");
             raise (Failure "The Web app failed!"));
       ]
