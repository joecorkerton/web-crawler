import gleam/httpc
import gleam/http.{Get, Response}
import gleam/dynamic.{Dynamic}
import gleam/io
import gleam/string

pub opaque type Url {
  Url(host: String, path: String)
}

pub fn parse_url(input: String) -> Result(Url, String) {
  case string.contains(input, contain: "://") {
    True -> {
      let [_, body] = string.split(input, on: "://")
      case string.split_once(body, on: "/"), body {
        Ok(tuple(host, path)), _ -> Ok(Url(host, path))
        Error(Nil), "" -> Error("Bad input string")
        Error(Nil), _ -> Ok(Url(body, ""))
      }
    }
    False -> Error("Bad input string")
  }
}

pub fn url_host(url: Url) -> String {
  url.host
}

pub fn url_path(url: Url) -> String {
  url.path
}

pub fn get(url: Url) -> Result(Response(String), Dynamic) {
  let request =
    http.default_req()
    |> http.set_method(Get)
    |> http.set_host(url.host)
    |> http.set_path(url.path)

  let response = httpc.send(request)

  io.debug(response)
  response
}
