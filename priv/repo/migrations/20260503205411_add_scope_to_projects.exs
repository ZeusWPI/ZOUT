defmodule Zout.Repo.Migrations.AddScopeToProjects do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE scope_type AS ENUM ('public', 'bestuur', 'internal')",
      "DROP TYPE scope_type"
    )

    alter table(:projects) do
      add :scope, :scope_type, null: false, default: "public"
    end
  end
end
