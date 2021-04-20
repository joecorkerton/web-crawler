# web_crawler

A Gleam project

## Quick start

```sh
# Run the eunit tests
rebar3 eunit

# Run the Erlang REPL
rebar3 shell
```

## Details

### Please complete the user story below
Your code should compile and run in one step
Write it as you would write a production ready feature
Feel free to use whatever frameworks/languages/libraries/packages you like

As a user running the application
I can enter a web URL to be crawled
So that I can generate and view a visual representation of the static assets each page depends on and the links between the pages.

### Conditions of Satisfaction
The crawler should be limited to one domain - so when crawling https://elixir-lang.org/ it would crawl all pages within the domain, but not follow external links, for example to the Facebook and Twitter accounts.

Given a URL, it should output a site map, showing which static assets each page depends on, and the links between pages.

The resultant generated site map can be as simple as a text file or a snazzy, detailed webpage report.

Bonus points for tests and making it as fast as possible!

You’ll be asked to talk through your code during the next interview round.
