let index = [%blob "frontend/index.html"]
let favicon = [%blob "frontend/icon.png"]
let css = [%blob "frontend/style.css"]

let new_url db secret =
 fun req ->
  (* Authentication uses the submitted secret, not session cookies. *)
  Lwt.bind (Dream.form ~csrf:false req) (fun form ->
      match form with
      | `Ok [ ("secret", s); ("url", url) ] ->
          if secret = s then Db.put db url |> Dream.respond
          else Dream.respond ~status:`Unauthorized "Unauthorized"
      | _ -> Dream.empty `Bad_Request)

let get_url db =
 fun req -> Dream.param req "code" |> Db.get db |> Dream.redirect req

let routes db secret =
  [
    Dream.get "/" (fun _ -> Dream.html index);
    Dream.get "/index.html" (fun _ -> Dream.html index);
    Dream.get "/style.css" (fun _ ->
        Dream.respond ~headers:[ ("Content-Type", "text/css") ] css);
    Dream.get "/icon.png" (fun _ ->
        Dream.respond ~headers:[ ("Content-Type", "image/png") ] favicon);
    Dream.post "/new" @@ new_url db secret;
    Dream.get "/su/:code" @@ get_url db;
  ]
