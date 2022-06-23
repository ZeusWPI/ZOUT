defmodule Zout.Repo.Migrations.RestoreSlug do
  use Ecto.Migration

  def change do
    # Add column
    alter table(:projects) do
      add :slug, :string
    end

    # Add slugs for existing stuff
    execute("UPDATE projects SET slug = 'slug-' || random() WHERE slug IS NULL")
    # Make slugs unique and required
    alter table(:projects) do
      modify :slug, :string, null: false
    end

    create unique_index(:projects, [:slug])
  end
end
