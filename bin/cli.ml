type cli = {
  version : bool;
  delete : bool;
  listen_addr : string;
  secret : string option;
  database_path : string;
  tls : bool;
  cert_path : string;
  key_path : string;
}

let help_menu =
  "Usage: us [OPTIONS]\n\n\
   Private URL shortener.\n\n\
   --secret/-s is required for running the server.\n\n\
   Options:"

let version_string = "us 0.1.0"

let args =
  let version = ref false in
  let delete = ref false in
  let listen_addr = ref "[::]:8913" in
  let secret = ref None in
  let database_path = ref "urls" in
  let tls = ref false in
  let cert_path = ref "" in
  let key_path = ref "" in

  let options =
    [
      ("--version", Arg.Set version, " Display version and exit");
      ("-v", Arg.Set version, " Display version and exit");
      ("--delete", Arg.Set delete, " Delete all stored URLs and exit");
      ("-D", Arg.Set delete, " Delete all stored URLs and exit");
      ( "--listen-addr",
        Arg.Set_string listen_addr,
        "ADDR Listening address (host:port; default: [::]:8913)" );
      ("-l", Arg.Set_string listen_addr, "ADDR Listening address (host:port)");
      ( "--secret",
        Arg.String (fun value -> secret := Some value),
        "SECRET Authentication secret (required)" );
      ( "-s",
        Arg.String (fun value -> secret := Some value),
        "SECRET Authentication secret (required)" );
      ( "--database-path",
        Arg.Set_string database_path,
        "PATH Database file path (default: urls)" );
      ("-d", Arg.Set_string database_path, "PATH Database file path");
      ( "--tls",
        Arg.Bool (fun value -> tls := value),
        "BOOL Enable or disable TLS (default: false)" );
      ( "-t",
        Arg.Bool (fun value -> tls := value),
        "BOOL Enable or disable TLS (true/false)" );
      ("--cert-path", Arg.Set_string cert_path, "PATH TLS certificate file path");
      ("-C", Arg.Set_string cert_path, "PATH TLS certificate file path");
      ("--key-path", Arg.Set_string key_path, "PATH TLS private key file path");
      ("-k", Arg.Set_string key_path, "PATH TLS private key file path");
    ]
  in
  Arg.parse
    (options
    @ [
        ( "-h",
          Arg.Unit
            (fun () -> raise (Arg.Help (Arg.usage_string options help_menu))),
          " Display help and exit" );
      ])
    (fun a -> raise (Arg.Bad (Printf.sprintf "Unknown command %s" a)))
    help_menu;

  {
    version = !version;
    delete = !delete;
    listen_addr = !listen_addr;
    secret = !secret;
    database_path = !database_path;
    tls = !tls;
    cert_path = !cert_path;
    key_path = !key_path;
  }
