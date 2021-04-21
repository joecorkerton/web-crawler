import gleam/io
import gleam/list

pub external type CharList

pub fn hello_world() -> String {
  "Hello, from web_crawler!"
}

pub fn main(input: List(CharList)) {
  let args = list.map(input, char_list_to_string)

  io.debug(args)
  io.println("nice")
}

external fn char_list_to_string(CharList) -> String =
  "erlang" "list_to_binary"
