[
  import_deps: [:ecto, :phoenix, :ecto_sql],
  inputs: ["*.{ex,exs,heex}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs,heex}"],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
]
