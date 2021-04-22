import gleam/httpc
import gleam/http.{Get, Response}
import gleam/list
import gleam/set.{Set}
import gleam/string
import gleam/string_builder
import gleam/result
import gleam/regex.{Match}

pub opaque type Url {
  Url(host: String, path: String, links: Set(String))
}

pub fn parse(input: String) -> Result(Url, String) {
  case string.contains(input, contain: "://") {
    True -> {
      let [_, body] = string.split(input, on: "://")
      case string.split_once(body, on: "/"), body {
        Ok(tuple(host, path)), _ -> Ok(Url(host, path, set.new()))
        Error(Nil), "" -> Error("Bad input string")
        Error(Nil), _ -> Ok(Url(body, "", set.new()))
      }
    }
    False -> Error("Bad input string")
  }
}

pub fn parse_sublink(original_url: Url, input: String) -> Result(Url, String) {
  input
  |> parse()
  |> result.then(fn(url: Url) {
    case url.host == original_url.host {
      True -> Ok(url)
      False -> Error("Not on same domain as original url")
    }
  })
}

pub fn host(url: Url) -> String {
  url.host
}

pub fn path(url: Url) -> String {
  url.path
}

pub fn links(url: Url) -> Set(String) {
  url.links
}

pub fn to_link(url: Url) -> String {
  string.concat(["https://", url.host, "/", url.path])
}

pub fn set_links(url: Url, links: List(String)) -> Url {
  Url(..url, links: set.from_list(links))
}

pub fn to_output(url: Url) -> String {
  let links_list =
    url.links
    |> set.to_list()
    |> list.intersperse(",\n- ")

  ["\n", url.host, "/", url.path, " links to: \n- "]
  |> list.append(links_list)
  |> string_builder.from_strings()
  |> string_builder.to_string()
}

pub fn get(url: Url) -> Result(String, String) {
  http.default_req()
  |> http.set_method(Get)
  |> http.set_host(url.host)
  |> http.set_path(url.path)
  |> httpc.send()
  |> result.replace_error("Bad request")
  |> result.then(fn(response: Response(String)) {
    case response.status {
      200 -> Ok(response.body)
      _ -> Error("Bad status code")
    }
  })
}

pub fn extract_links_from_body(body: String) -> List(String) {
  let Ok(re) =
    regex.from_string(
      "(http|https)://([\\w_-]+(?:(?:\\.[\\w_-]+)+))([\\w.,@?^=%&:/~+#-]*[\\w@?^=%&/~+#-])?",
    )

  regex.scan(re, body)
  |> list.map(fn(match: Match) { match.content })
}
