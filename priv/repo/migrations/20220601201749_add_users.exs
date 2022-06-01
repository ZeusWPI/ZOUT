defmodule Zout.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :integer, primary_key: true
      add :nickname, :string, null: false
      add :admin, :boolean, null: false, default: false

      timestamps()
    end

    create index(:users, :nickname, unique: true)
  end
end
