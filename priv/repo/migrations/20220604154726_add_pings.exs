defmodule Zout.Repo.Migrations.AddPings do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE ping_result AS ENUM ('offline', 'working', 'failing')"
    drop_query = "DROP TYPE ping_result"
    execute(create_query, drop_query)

    create table(:pings, primary_key: false) do
      add :stamp, :utc_datetime
      add :status, :ping_result
      add :project_id, references(:projects, on_delete: :delete_all)
      add :message, :string
      add :response_time, :integer
    end

    execute("SELECT create_hypertable('pings', 'stamp')")

    create index(:pings, [:project_id, "stamp DESC"])
  end
end
