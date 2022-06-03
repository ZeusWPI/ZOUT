defmodule Zout.Repo.Migrations.SoftDeleteProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :deleted, :boolean, null: false, default: false
    end
  end
end
