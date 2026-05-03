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

projects = [
  %Project{
    name: "Zeus WPI",
    slug: "zeus-site",
    checker: :http_ok,
    params: %{url: "https://zeus.ugent.be"},
    inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
    updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  },
  %Project{
    name: "Weus ZPI",
    slug: "weus-site",
    checker: :http_ok,
    params: %{url: "https://weus.ugent.be"},
    inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
    updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  }
]

projects
|> Enum.map(fn el ->
  if Repo.get_by(Project, name: el.name) === nil and
       Repo.get_by(Project, slug: el.slug) === nil do
    Repo.insert!(el)
  end
end)
