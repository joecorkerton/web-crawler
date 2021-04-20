import web_crawler
import gleam/should

pub fn hello_world_test() {
  web_crawler.hello_world()
  |> should.equal("Hello, from web_crawler!")
}
