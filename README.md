# Zout [![Elixir CI](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml/badge.svg)](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml) [![Coverage Status](https://coveralls.io/repos/github/ZeusWPI/ZOUT/badge.svg?branch=master)](https://coveralls.io/github/ZeusWPI/ZOUT?branch=master)

Het Zeus Overzicht met Uitgebreide Toestanden ("Zeus Overview with Extensive)

The aim of this project is to provide an "uptime monitor" for Zeus projects.
Why use an existing solution, when you can build it yourself?

Anyway, this application is rather simple.
It has a list of projects, for which it pings some URL every X time, and saves the result in a big PostgreSQL table (we use TimescaleDB, so we can save all the things).
We then show this with a simple UI.

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
Note that once the server runs, it will ping registered services every minute or so,
so don't leave it running too long in the background.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
