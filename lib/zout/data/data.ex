defmodule Zout.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Zout.Repo

  alias Zout.Data.Project
  alias Zout.Data.Ping
  alias Zout.Data.Dependency
  alias Zout.Checker

  @doc """
  Returns the list of projects.
  """
  def list_projects(deleted \\ false) do
    Project
    |> where(deleted: ^deleted)
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises if the Project does not exist.
  """
  def get_project!(id), do: Repo.get!(Project, id) |> Repo.preload(:dependencies)

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    # Handle dependencies properly.
    ids = Map.get(attrs, "dependency_ids", [])
    deps = Repo.all(from p in Project, where: p.id in ^ids)

    attrs = Map.put(attrs, "dependencies", deps)

    change_project(%Project{dependencies: []}, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.
  """
  def update_project(%Project{} = project, attrs) do
    # Handle dependencies properly.
    ids = Map.get(attrs, "dependency_ids", [])
    deps = Repo.all(from p in Project, where: p.id in ^ids)

    attrs = Map.put(attrs, "dependencies", deps)

    change_project(project, attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.
  """
  def delete_project(%Project{} = project) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking project changes.
  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  List all projects and status information.

  The returned list will contain each active project, with:

  - The latest ping to display the current status (`ping`).
  - The lastet ping with a different status (`last_ping`).

  Note that this last one cheats a bit: to be exact, we would want the earliest
  ping in the previous sequence of pings with a different status (the pings in
  a sequence all have the same status).

  For example, if there are two failing pings A, B, followed by three offline
  ping C, D, E, this function would current return E as first ping and B as the
  second ping. However, ideally we would want C as the second ping. However, I
  haven't figured out the SQL for thas.

  """
  def list_projects_and_status do
    most_recent_ping_query =
      Ping
      |> distinct(:project_id)
      |> order_by([:project_id, desc: :stamp])

    Project
    |> where(deleted: false)
    |> join(:left, [p], c in subquery(most_recent_ping_query), on: p.id == c.project_id)
    |> join(
      :left_lateral,
      [p, c],
      d in fragment(
        "(SELECT DISTINCT ON (project_id) * FROM pings WHERE status != ? ORDER BY project_id, stamp DESC)",
        c.status
      ),
      on: p.id == d.project_id
    )
    |> select([p, c, d], %{project: p, ping: c, last_ping: %{stamp: d.stamp, status: d.status}})
    |> Repo.all()
  end

  @doc """
  Get the most recent pings in the last `limit` hours for a project.
  """
  @spec recent_pings(%Project{}, Timex.shift_options()) :: [%Ping{}]
  def recent_pings(%Project{id: id}, duration) do
    ago = Timex.now() |> Timex.shift(duration)

    Ping
    |> where([p], p.project_id == ^id and p.stamp >= ^ago)
    |> order_by(desc: :stamp)
    |> limit(10000)
    |> Repo.all()
  end

  @doc """
  Get recent pings for all projects.
  TODO: how does this perform with a lot of pings? Who knows.
  """
  def all_recent_pings(duration) do
    ago = Timex.now() |> Timex.shift(duration)

    Project
    |> join(
      :inner_lateral,
      [p],
      pi in fragment(
        """
        SELECT * FROM pings
        WHERE project_id = ? and stamp > ?
        ORDER BY stamp DESC
        LIMIT 2000
        """,
        p.id,
        ^ago
      ),
      on: true
    )
    |> select([p, pi], %{
      project: %{id: p.id, name: p.name},
      ping: %{status: pi.status, stamp: pi.stamp}
    })
    |> Repo.all()
  end

  defp handle_check_result(%Project{id: id}, {status, message, response_time}) do
    Repo.insert!(%Ping{
      stamp: DateTime.utc_now() |> DateTime.truncate(:second),
      project_id: id,
      status: status,
      message: message,
      response_time: response_time
    })
  end

  @doc """
  Run the checker for each project.

  This will save the results to the database if needed, but will not return
  anything.
  """
  def check_all_projects do
    projects = list_projects()

    Enum.each(projects, fn project ->
      check_module = Checker.checker(project.checker)
      result = check_module.check(project.params)
      handle_check_result(project, result)
    end)
  end

  @doc """
  List the dependencies for the given projects.
  """
  def list_dependencies(projects) do
    ids =
      Enum.map(projects, fn
        %Project{id: id} -> id
        %{project: p} -> p.id
      end)

    Repo.all(from d in Dependency, where: d.from_id in ^ids)
  end
end
