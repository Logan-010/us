type cli = {
  version : bool;
  config : string option;
  listen_addr : string option;
  secret : string option;
  database_path : string option;
  tls : bool option;
  cert_path : string option;
  key_path : string option;
}

let help_menu =
  "Usage: us [OPTIONS]\n\nPrivate URL shortener.\n\nCLI options override values in the config file.\n\nOptions:"

let version_string = "us 0.1.0"

let args =
  let version = ref false in
  let config = ref None in
  let listen_addr = ref None in
  let secret = ref None in
  let database_path = ref None in
  let tls = ref None in
  let cert_path = ref None in
  let key_path = ref None in
  let set_string field = Arg.String (fun value -> field := Some value) in

  let options =
    [
      ("--version", Arg.Set version, " Display version and exit");
      ("-v", Arg.Set version, " Display version and exit");
      ("--config", set_string config, "PATH Load configuration from PATH");
      ("-c", set_string config, "PATH Load configuration from PATH");
      ("--listen-addr", set_string listen_addr, "ADDR Listening address (host:port)");
      ("-l", set_string listen_addr, "ADDR Listening address (host:port)");
      ("--secret", set_string secret, "SECRET Authentication secret");
      ("-s", set_string secret, "SECRET Authentication secret");
      ("--database-path", set_string database_path, "PATH Database file path");
      ("-d", set_string database_path, "PATH Database file path");
      ( "--tls",
        Arg.Bool (fun value -> tls := Some value),
        "BOOL Enable or disable TLS (true/false)" );
      ( "-t",
        Arg.Bool (fun value -> tls := Some value),
        "BOOL Enable or disable TLS (true/false)" );
      ("--cert-path", set_string cert_path, "PATH TLS certificate file path");
      ("-C", set_string cert_path, "PATH TLS certificate file path");
      ("--key-path", set_string key_path, "PATH TLS private key file path");
      ("-k", set_string key_path, "PATH TLS private key file path");
    ]
  in
  Arg.parse
    (options
    @ [
        ( "-h",
          Arg.Unit (fun () -> raise (Arg.Help (Arg.usage_string options help_menu))),
          " Display help and exit" );
      ])
    (fun a -> raise (Arg.Bad (Printf.sprintf "Unknown command %s" a)))
    help_menu;

  {
    version = !version;
    config = !config;
    listen_addr = !listen_addr;
    secret = !secret;
    database_path = !database_path;
    tls = !tls;
    cert_path = !cert_path;
    key_path = !key_path;
  }

let override_config (config : Config.config) =
  {
    Config.listen_addr = Option.value ~default:config.listen_addr args.listen_addr;
    secret = Option.value ~default:config.secret args.secret;
    database_path = Option.value ~default:config.database_path args.database_path;
    tls = (match args.tls with Some _ -> args.tls | None -> config.tls);
    cert_path =
      (match args.cert_path with Some _ -> args.cert_path | None -> config.cert_path);
    key_path =
      (match args.key_path with Some _ -> args.key_path | None -> config.key_path);
  }
