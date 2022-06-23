defmodule Zout.Repo.Migrations.AddUnchecked do
  use Ecto.Migration

  def change do
    execute("ALTER TYPE check_type ADD VALUE 'unchecked';")
  end
end
