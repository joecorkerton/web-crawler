import url
import gleam/should
import gleam/string
import gleam/http
import gleam/set

pub const elixir_url = "https://elixir-lang.org/blog/2020/10/06/elixir-v1-11-0-released/"

pub const other_host_url = "http://www.google.com"

pub fn parse_test() {
  let Ok(url) = url.parse(elixir_url)

  url
  |> url.host()
  |> should.equal("elixir-lang.org")

  url
  |> url.path()
  |> should.equal("blog/2020/10/06/elixir-v1-11-0-released/")
}

pub fn parse_with_bad_input_test() {
  url.parse("BAD URL!")
  |> should.be_error()
}

pub fn parse_with_strange_input_test() {
  url.parse("https://gitpod.io/#https://github.com/codec-abc/gitpod-gleam")
  |> should.be_ok()
}

pub fn set_links_test() {
  let Ok(url) = url.parse(elixir_url)

  url
  |> url.set_links(["link-1", "link-2", "link-1"])
  |> url.links()
  |> should.equal(set.from_list(["link-1", "link-2"]))
}

pub fn to_output_test() {
  let Ok(url) = url.parse(elixir_url)

  url
  |> url.set_links([
    "elixir-lang.org/an-important-link", "elixir-lang.org/jose-valim",
  ])
  |> url.to_output()
  |> should.equal(
    "\nelixir-lang.org/blog/2020/10/06/elixir-v1-11-0-released/ links to: \n- elixir-lang.org/an-important-link,\n- elixir-lang.org/jose-valim",
  )
}

pub fn to_link_test() {
  let Ok(url) = url.parse(elixir_url)
  url
  |> url.to_link()
  |> should.equal(elixir_url)
}

pub fn parse_sublink_doesnt_parse_links_on_different_hosts_test() {
  let Ok(url) = url.parse(elixir_url)

  url.parse(other_host_url)
  |> should.be_ok()

  url.parse_sublink(url, other_host_url)
  |> should.be_error()
}

pub fn get_test() {
  let Ok(url) = url.parse(elixir_url)
  let Ok(response) = url.get(url)

  response
  |> string.contains(
    "Over the last releases, the Elixir team has been focusing on the compiler",
  )
  |> should.be_true()
}

pub fn extract_links_from_body_test() {
  let body =
    "<html><title><a href=\"http://www.google.com\">Link!</a><span>https://elixir-lang.org</span></title></html>"

  body
  |> url.extract_links_from_body
  |> should.equal(["http://www.google.com", "https://elixir-lang.org"])
}
