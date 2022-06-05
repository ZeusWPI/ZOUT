defmodule Zout.Repo.Migrations.RemoveDowntimes do
  use Ecto.Migration

  def change do
    drop table(:downtimes)
  end
end
