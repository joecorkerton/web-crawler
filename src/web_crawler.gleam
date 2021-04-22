import url.{Url}
import gleam/io
import gleam/list
import gleam/set.{Set}
import gleam/result

pub external type CharList

pub fn main(input: List(CharList)) {
  case list.head(input) {
    Ok(char_list) -> {
      let parsed_url =
        char_list_to_string(char_list)
        |> url.parse()
      case parsed_url {
        Ok(url) -> build_sitemap(url)
        Error(error) -> io.println(error)
      }
    }
    Error(Nil) -> io.println("You need to provide a domain to crawl")
  }
}

external fn char_list_to_string(CharList) -> String =
  "erlang" "list_to_binary"

fn build_sitemap(initial_url: Url) -> Nil {
  let uncrawled_links =
    [url.to_link(initial_url)]
    |> set.from_list()
  iterate_through_links(initial_url, set.new(), uncrawled_links)
  |> io.debug()
  io.println("Done")
}

fn iterate_through_links(
  initial_url: Url,
  crawled_urls: Set(Url),
  uncrawled_links: Set(String),
) -> Set(Url) {
  case set.size(uncrawled_links) {
    0 -> crawled_urls
    _ -> {
      let Ok(tuple(next_link, other_links)) =
        uncrawled_links
        |> set.to_list()
        |> list.pop(fn(_) { True })
      case url.parse_sublink(initial_url, next_link) {
        Error(_) ->
          iterate_through_links(
            initial_url,
            crawled_urls,
            set.from_list(other_links),
          )
        Ok(new_url) -> {
          let new_uncrawled_links =
            new_url
            |> url.get()
            |> result.map(fn(body) { url.extract_links_from_body(body) })
            |> result.unwrap(or: [])
            |> set.from_list()
          let new_url =
            [url.set_links(new_url, set.to_list(new_uncrawled_links))]
            |> set.from_list()
          iterate_through_links(
            initial_url,
            set.union(crawled_urls, new_url),
            set.union(uncrawled_links, new_uncrawled_links),
          )
        }
      }
    }
  }
}
