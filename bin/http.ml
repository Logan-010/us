let index = [%blob "frontend/index.html"]
let favicon = [%blob "frontend/icon.png"]
let css = [%blob "frontend/style.css"]

let new_url req = Dream.log "New URL"; Dream.respond "TODO"

let routes db =
  [
    Dream.get "/" (fun _ -> Dream.html index);
    Dream.get "/index.html" (fun _ -> Dream.html index);
    Dream.get "/style.css" (fun _ ->
        Dream.respond ~headers:[ ("Content-Type", "text/css") ] css);
    Dream.get "/icon.png" (fun _ ->
        Dream.respond ~headers:[ ("Content-Type", "image/png") ] favicon);
    Dream.post "/new" new_url;
  ]
