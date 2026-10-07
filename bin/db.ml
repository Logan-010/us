open Dokeysto.Db

let charset =
  "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789"

let generate_code () =
  Random.self_init ();
  String.init 4 (fun _ ->
    charset.[Random.int (String.length charset)]
  )

let init path =
  if Sys.file_exists path then RW.open_existing path
  else
    let db = RW.create path in
    RW.sync db;
    db

let cleanup db =
  let codes = RW.fold (fun code _ codes -> code :: codes) db [] in
  List.iter (RW.remove db) codes;
  RW.sync db

let put db url =
  let existing =
    RW.fold
      (fun code stored_url found ->
        if stored_url = url then Some code else found)
      db None
  in
  match existing with
  | Some code -> code
  | None ->
      let rec unused_code () =
        let code = generate_code () in
        if RW.mem db code then unused_code () else code
      in
      let code = unused_code () in
      Dream.log "Adding URL \"%s\" under \"%s\"" url code;
      RW.add db code url;
      RW.sync db;
      code

let get db code = RW.find db code
