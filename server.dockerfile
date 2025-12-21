FROM elixir:1.19-alpine AS builder

# install build dependencies
RUN apk add --no-cache npm

# sets work dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# copy stuff
COPY priv priv
COPY lib lib
COPY assets assets

# node dependencies
RUN cd assets && npm ci

# compile assets
RUN mix assets.deploy

# compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# app stage
FROM alpine:3.21 AS app

# install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs musl-locales

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/zout ./

USER nobody
CMD ["/app/bin/server"]
