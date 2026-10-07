type cli = { version : bool; config : string option }

let help_menu = "TODO"

let args =
  let version = ref false in
  let config = ref None in

  Arg.parse
    [
      ("version", Arg.Set version, "Display version");
      ("v", Arg.Set version, "version (short)");
    ]
    (fun a -> invalid_arg @@ Printf.sprintf "Unknown command %s" a)
    help_menu;

  { version = !version; config = !config }
