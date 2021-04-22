import url.{Url}
import gleam/io
import gleam/list
import gleam/set.{Set}
import gleam/result
import gleam/dynamic.{Dynamic}
import gleam/atom.{Atom}
import gleam/string

pub external type CharList

pub fn main(input: List(CharList)) {
  start_application_and_deps(atom.create_from_string("web_crawler"))
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

fn build_sitemap(initial_url: Url) -> Nil {
  let uncrawled_links =
    [url.to_link(initial_url)]
    |> set.from_list()
  initial_url
  |> iterate_through_links(set.new(), uncrawled_links)
  |> set.to_list()
  |> list.each(fn(url) {
    url
    |> url.to_output()
    |> io.println()
  })
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
          let new_url_set =
            [url.set_links(new_url, set.to_list(new_uncrawled_links))]
            |> set.from_list()
          io.println(string.append("processed url ", url.to_link(new_url)))
          let new_crawled_urls = set.union(crawled_urls, new_url_set)
          iterate_through_links(
            initial_url,
            new_crawled_urls,
            uncrawled_links
            |> set.union(new_uncrawled_links)
            |> remove_already_crawled_urls_from_links(new_crawled_urls),
          )
        }
      }
    }
  }
}

fn remove_already_crawled_urls_from_links(
  links: Set(String),
  crawled_urls: Set(Url),
) -> Set(String) {
  crawled_urls
  |> set.to_list()
  |> list.map(fn(url) { url.to_link(url) })
  |> list.fold(
    from: links,
    with: fn(crawled_url, uncrawled_links) {
      set.delete(uncrawled_links, crawled_url)
    },
  )
}

external fn char_list_to_string(CharList) -> String =
  "erlang" "list_to_binary"

external fn start_application_and_deps(Atom) -> Dynamic =
  "application" "ensure_all_started"
