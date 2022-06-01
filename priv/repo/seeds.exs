# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Zout.Repo.insert!(%Zout.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Zout.Repo
alias Zout.Data.Project

%Project{
  name: "Zeus WPI",
  slug: "zeus-site",
  checker: :http_ok,
  params: %{url: "https://zeus.ugent.be"},
  inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
  updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
}
|> Repo.insert!()

%Project{
  name: "Weus ZPI",
  slug: "weus-site",
  checker: :http_ok,
  params: %{url: "https://weus.ugent.be"},
  inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
  updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
}
|> Repo.insert!()
