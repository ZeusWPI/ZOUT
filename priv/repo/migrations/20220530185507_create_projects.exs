defmodule Zout.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE check_type AS ENUM ('http_ok')"
    drop_query = "DROP TYPE check_type"
    execute(create_query, drop_query)

    create table(:projects) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :source, :string
      add :home, :string
      add :checker, :check_type
      add :params, :map

      timestamps()
    end

    create index(:projects, :name, unique: true)
    create index(:projects, :slug, unique: true)
  end
end
