type config = {
  listen_addr : string;
  secret : string;
  database_path : string;
  tls : bool option;
  cert_path : string option;
  key_path : string option;
}

exception TomlException of string

let default_config =
  {
    listen_addr = "[::]:8913";
    secret = "change me!";
    database_path = "urls.database";
    tls = None;
    cert_path = None;
    key_path = None;
  }

let config_to_toml config =
  let open Toml.Types in
  let fields =
    [
      (Toml.Min.key "listen_addr", TString config.listen_addr);
      (Toml.Min.key "secret", TString config.secret);
      (Toml.Min.key "database_path", TString config.database_path);
    ]
  in
  let fields =
    match config.tls with
    | Some v -> fields @ [ (Toml.Min.key "tls", TBool v) ]
    | None -> fields
  in
  let fields =
    match config.cert_path with
    | Some v -> fields @ [ (Toml.Min.key "cert_path", TString v) ]
    | None -> fields
  in
  let fields =
    match config.key_path with
    | Some v -> fields @ [ (Toml.Min.key "key_path", TString v) ]
    | None -> fields
  in
  Toml.Min.of_key_values fields

let default_config_string =
  Toml.Printer.string_of_table @@ config_to_toml default_config

let parse_config data =
  let table =
    match Toml.Parser.from_string data with
    | `Ok v -> v
    | `Error (e, _) -> raise (TomlException e)
  in
  let get_string field =
    match
      Toml.Lenses.get table
        (Toml.Lenses.( |-- ) (Toml.Lenses.key field) Toml.Lenses.string)
    with
    | Some value -> value
    | None -> raise (TomlException ("Missing or invalid field: " ^ field))
  in
  let get_optional_string field =
    Toml.Lenses.get table
      (Toml.Lenses.( |-- ) (Toml.Lenses.key field) Toml.Lenses.string)
  in
  let get_optional_bool field =
    Toml.Lenses.get table
      (Toml.Lenses.( |-- ) (Toml.Lenses.key field) Toml.Lenses.bool)
  in
  {
    listen_addr = get_string "listen_addr";
    secret = get_string "secret";
    database_path = get_string "database_path";
    tls = get_optional_bool "tls";
    cert_path = get_optional_string "cert_path";
    key_path = get_optional_string "key_path";
  }
