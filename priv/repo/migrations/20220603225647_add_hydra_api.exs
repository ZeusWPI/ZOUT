defmodule Zout.Repo.Migrations.AddHydraApi do
  use Ecto.Migration

  def change do
    execute("ALTER TYPE check_type ADD VALUE 'hydra_api';")
  end
end
