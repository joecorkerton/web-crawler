import request
import gleam/io
import gleam/list

pub external type CharList

pub fn main(input: List(CharList)) {
  case list.head(input) {
    Ok(char_list) -> {
      let url = char_list_to_string(char_list)
      True
    }
    Error(Nil) -> {
      io.println("You need to provide a domain to crawl")
      False
    }
  }

  io.println("nice")
}

external fn char_list_to_string(CharList) -> String =
  "erlang" "list_to_binary"
