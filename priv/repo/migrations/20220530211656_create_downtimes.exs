defmodule Zout.Repo.Migrations.CreateDowntimes do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE downtime_status AS ENUM ('offline', 'working', 'failing')"
    drop_query = "DROP TYPE downtime_status"
    execute(create_query, drop_query)

    create table(:downtimes) do
      add :start, :utc_datetime, null: false
      add :end, :utc_datetime
      add :project_id, references(:projects, on_delete: :delete_all)
      add :status, :downtime_status

      timestamps()
    end

    create index(:downtimes, [:project_id])
  end
end
