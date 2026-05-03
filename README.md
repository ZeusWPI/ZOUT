# Zout [![Elixir CI](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml/badge.svg)](https://github.com/ZeusWPI/ZOUT/actions/workflows/elixir.yml) [![Coverage Status](https://coveralls.io/repos/github/ZeusWPI/ZOUT/badge.svg?branch=master)](https://coveralls.io/github/ZeusWPI/ZOUT?branch=master)

Het Zeus Overzicht met Uitgebreide Toestanden ("Zeus Overview Using exTensive states")

The aim of this project is to provide an "uptime monitor" for Zeus projects.
Why use an existing solution, when you can build it yourself?

Anyway, this application is rather simple.
It has a list of projects, for which it pings some URL every X time, and saves the result in a big PostgreSQL table (we use TimescaleDB, so we can save all the things).
We then show this with a simple UI.

## Setting up a dev environment

> Note: Once the server runs, it will ping registered services every minute or so, so don't leave it running too long in the background.

Combine any of the following:

### Nix (everything)

Enlightened people can use the nix flake.

After setting up the database, run the webserver as follows:

```console
mix setup
mix phx.server
```

Now, visit [http://localhost:4000](http://localhost:4000)

### Guix (everything except database)

Slightly more enlightened people can run the webserver like this:

```console
guix shell -mmanifest.scm -CFN -ETERM -- sh -c "mix setup; mix phx.server"
```

Now, visit [http://localhost:4000](http://localhost:4000)

### Others (everything except database)

Install the following:

- Elixir 1.19
- Node.js 24

Start the webserver:

```console
mix setup
mix phx.server
```

Now, visit [http://localhost:4000](http://localhost:4000)

### Docker/Podman (database only)

Start a development postgres, accessible on `postgresql://postgres:postgres@localhost` :

```console
podman compose -fdocker-compose.dev.yml up -d --build
```

### Others (database only)

Set up a PostgreSQL 17 with the TimescaleDB extension.
Make sure it's accessible on: `postgresql://postgres:postgres@localhost`

## Deployment

> Note: This is done automatically upon pushing to master.
>
> See [workflows/deploy.yml](.github/workflows/deploy.yml) and [deploy.ssh](deploy.ssh).

1. SSH to the server
2. Pull the repo
3. Take the application down with `podman-compose down`.
4. Build a new docker image with `podman-compose build`
5. Start the application with `podman-compose up -d`

## Learn more about the Phoenix framework

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
