# Zout [![Elixir CI](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml/badge.svg)](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml) [![Coverage Status](https://coveralls.io/repos/github/ZeusWPI/ZOUT/badge.svg?branch=master)](https://coveralls.io/github/ZeusWPI/ZOUT?branch=master)

## Installing dev environment

Enlightened people can use the nix flake.
Others need to search how to install:

- Elixir 1.13
- PostgreSQL 14
- TimescaleDB extension for PostgresSQL
- Node

Then, to start your Phoenix server:

  * Install asset dependencies with `cd assets && npm install`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
