defmodule Zout.Repo.Migrations.ConvertToInterval do
  use Ecto.Migration

  def change do
    # Create our new table.
    # We cannot use a primary key, since timescaledb requires all unique indices to include the start column.
    create table(:pings_temp, primary_key: false) do
      add(:start, :utc_datetime, null: false)
      add(:stop, :utc_datetime, null: false)
      add(:status, :ping_result)
      add(:project_id, references(:projects, on_delete: :delete_all))
      add(:message, :text)
    end

    # Convert it to a hypertable, using the start column as the partitioning column.
    # This should be better, since they don't change.
    execute("SELECT create_hypertable('pings_temp', 'start')")

    # Simulate a primary key.
    create(unique_index(:pings_temp, [:project_id, :start]))
    # We search on project id a lot.
    create(index(:pings_temp, [:project_id]))
    create(index(:pings_temp, [:project_id, :status, :start]))

    # Convert all data.
    execute(fn ->
      # Start by getting all the projects we have.
      %{rows: projects} = repo().query!("SELECT DISTINCT project_id FROM pings")
      project_ids = List.flatten(projects)

      # Convert all data for each project.
      for project_id <- project_ids do
        accumulator = %{intervals: [], current: nil}
        %{rows: all_pings} = repo().query!("SELECT * FROM pings WHERE project_id = #{project_id}")

        %{intervals: intervals, current: current} =
          Enum.reduce(all_pings, accumulator, fn ping,
                                                 %{intervals: intervals, current: current} ->
            # We start a new interval if the current one is nil or of a different status of the current one.
            if is_nil(current) || current.status != Enum.at(ping, 1) do
              intervals =
                if !is_nil(current) do
                  [current | intervals]
                else
                  intervals
                end

              %{
                intervals: intervals,
                current: %{
                  project_id: Enum.at(ping, 2),
                  start: Enum.at(ping, 0),
                  stop: Enum.at(ping, 0),
                  status: Enum.at(ping, 1),
                  message: Enum.at(ping, 3)
                }
              }
            else
              %{
                intervals: intervals,
                current:
                  Map.merge(current, %{
                    stop: Enum.at(ping, 0),
                    message: Enum.at(ping, 3)
                  })
              }
            end
          end)

        new_pings = [current | intervals]

        repo().insert_all("pings_temp", new_pings)
      end
    end)

    # Remove the old table.
    rename table(:pings), to: table(:pings_old)

    # Rename the new table.
    rename table(:pings_temp), to: table(:pings)

    # Finally, drop the existing table
    drop table(:pings_old)
  end
end
