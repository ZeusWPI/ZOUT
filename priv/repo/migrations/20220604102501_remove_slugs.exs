defmodule Zout.Repo.Migrations.RemoveSlugs do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      remove :slug, :string
    end
  end
end
