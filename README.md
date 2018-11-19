# Issues

CLI for pulling issues from Github.

## Installation

With [Elixir](https://elixir-lang.org/) installed, run:

```shell
mix deps.get
mix escript.build
```

## Running

To fetch the last 10 issues from the Elixir Github repo:

```shell
./issues elixir-lang elixir 10
```

The arguments are passed like this:

```shell
issues <github user> <github project> [<number of issues>]
```

## Documentation

Generate docs with `mix docs` and browse them at `docs/index.html`.
