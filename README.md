# remote_data for Gleam

This package is inspired on the Elm package [RemoteData](https://package.elm-lang.org/packages/krisajenkins/remotedata/latest/).

[![Package Version](https://img.shields.io/hexpm/v/remote_data)](https://hex.pm/packages/remote_data)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/remote_data/)

## Installation

```sh
gleam add remote_data
```

## Usage

This example shows how to use the `remote_data` package in a [lustre](https://hexdocs.pm/lustre/index.html) application.

First you wrap the data you want to fetch in a `RemoteData` type:

```gleam
import remote_data.{type RemoteData} as rd
import lustre
import lustre/element
import lustre/element/html
import lustre_http.{type HttpError}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(quote: RemoteData(Quote, HttpError))
}

type Quote {
  Quote(author: String, content: String)
}
```

Initialize the model with `rd.NotAsked`:
```gleam
fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(quote: rd.NotAsked), effect.none())
}

```

When you want to fetch data, you can use the `rd.Loading` constructor to indicate that the data is being fetched.
When the data is fetched, you can use the `rd.from_result` to convert the `Result` to a `RemoteData` type:

```gleam
pub opaque type Msg {
  UserClickedRefresh
  ApiUpdatedQuote(Result(Quote, HttpError))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedRefresh -> #(Model(quote: rd.Loading), get_quote())
    ApiUpdatedQuote(quote) -> #(Model(quote: rd.from_result(quote)), effect.none())
  }
}

fn get_quote() -> Effect(Msg) {
  let url = "https://api.quotable.io/random"
  let decoder =
    dynamic.decode2(
      Quote,
      dynamic.field("author", dynamic.string),
      dynamic.field("content", dynamic.string),
    )

  lustre_http.get(url, lustre_http.expect_json(decoder, ApiUpdatedQuote))
}

```

Finally, you can pattern match on the `RemoteData` type to display the data in the view:

```gleam
fn view_quote(quote: RemoteData(Quote, HttpError)) -> Element(msg) {
  case quote {
    rd.Success(quote) ->
      html.div([], [
        element.text(quote.author <> " once said..."),
        html.p([attribute.style([#("font-style", "italic")])], [
          element.text(quote.content),
        ]),
      ])
    rd.NotAsked -> html.p([], [element.text("Click the button to get a quote!")])
    rd.Loading -> html.p([], [element.text("Fetching quote...")])
    rd.Failure(_) -> html.p([], [element.text("Failed to fetch quote!")])
  }
}
```

Further documentation can be found at <https://hexdocs.pm/remote_data>.
