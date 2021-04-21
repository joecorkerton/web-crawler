import request
import gleam/should
import gleam/string
import gleam/http

pub const elixir_url = "https://elixir-lang.org/blog/2020/10/06/elixir-v1-11-0-released/"

pub fn parse_url_test() {
  let Ok(url) = request.parse_url(elixir_url)

  url
  |> request.url_host()
  |> should.equal("elixir-lang.org")

  url
  |> request.url_path()
  |> should.equal("blog/2020/10/06/elixir-v1-11-0-released/")
}

pub fn parse_url_with_bad_input_test() {
  request.parse_url("BAD URL!")
  |> should.be_error()
}

pub fn get_test() {
  let Ok(url) = request.parse_url(elixir_url)
  let Ok(response) = request.get(url)

  response.status
  |> should.equal(200)

  response.body
  |> string.contains(
    "Over the last releases, the Elixir team has been focusing on the compiler",
  )
  |> should.be_true()
}
