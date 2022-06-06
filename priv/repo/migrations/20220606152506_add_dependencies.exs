defmodule Zout.Repo.Migrations.AddDependencies do
  use Ecto.Migration

  def change do
    create table(:dependencies, primary_key: false) do
      add :from_id, references(:projects, on_delete: :delete_all)
      add :to_id, references(:projects, on_delete: :delete_all)
    end

    create index(:dependencies, [:from_id])
    create index(:dependencies, [:to_id])
  end
end
