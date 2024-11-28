defmodule Zout.Data do
  @moduledoc """
  Manage application data.

  Responsible for managing `Project`s and `Ping`s.
  """

  import Ecto.Query, warn: false
  alias Zout.Repo

  alias Zout.Data.Project
  alias Zout.Data.Ping
  alias Zout.Data.Dependency
  alias Zout.Checker

  require Logger

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
  def get_project!(id) do
    Repo.get!(Project, id)
    |> Repo.preload(:dependencies)
  end

  @doc """
  Gets a single project by slug.

  Returns `nil` if the project doesn't exist.
  """
  def get_project_by_slug(slug),
    do: Repo.get_by(Project, slug: slug) |> Repo.preload(:dependencies)

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
  List all projects and the latest ping.

  The returned list contains a map with two properties:

  - `:project` - the project
  - `:ping` - the ping

  Note that the `:ping` may be `nil` if there are no pings for the project.
  """
  def list_projects_and_status do
    # Unfortunately, we cannot sort in the database :(
    Project
    |> where(deleted: false)
    |> join(:left, [p], c in Ping, on: c.project_id == p.id)
    |> order_by([p, c], [p.id, desc: c.stop])
    |> distinct([p, c], p.id)
    |> select([p, c], %{project: p, ping: c})
    |> Repo.all()
    |> Enum.sort_by(fn
      %{project: p, ping: nil} -> {true, p.name}
      %{project: p, ping: c} -> {c.status == :unchecked, p.name}
    end)
  end

  @doc """
  Get the most recent pings in the last `limit` hours for a project.
  """
  @spec recent_pings(%Project{}, Timex.shift_options()) :: [%Ping{}]
  def recent_pings(%Project{id: id}, duration) do
    ago = Timex.now() |> Timex.shift(duration)

    Ping
    |> where([p], p.project_id == ^id and (p.start > ^ago or p.stop > ^ago))
    |> order_by(desc: :stop)
    |> Repo.all()
  end

  @doc """
  Get recent pings for all projects.

  This will not include projects that only have "unchecked" pings.
  """
  def all_recent_pings(duration) do
    ago = Timex.now() |> Timex.shift(duration)

    Project
    |> where(deleted: false)
    |> join(:left, [p], c in Ping, on: c.project_id == p.id)
    |> order_by([p, c], [p.name, c.stop])
    |> where([p, c], c.status != :unchecked and (c.start > ^ago or c.stop > ^ago))
    |> select([p, c], %{project: p, ping: c})
    |> Repo.all()
  end

  @doc """
  Handle the result of a checker.

  This will consolidate the new ping with the existing ping, to only save intervals,
  to prevent ballooning the storage and processing requirements.
  """
  def handle_check_result(%Project{id: id}, {status, message, response_time}) do
    # Get the latest ping.
    # This should not be nil, unless this is the very first ping for a project.
    existing_ping =
      Ping
      |> where(project_id: ^id)
      |> last(:stop)
      |> Repo.one()

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Logger.info("Handling check result for project #{id} (#{status})")
    Logger.info("Existing ping: #{inspect(existing_ping)}")

    # If we don't have an existing ping or it is not of the same status,
    # begin a new interval.
    if is_nil(existing_ping) or existing_ping.status != status do
      Logger.info("Starting new ping interval")

      # Prevent multiple pings with the same end point.
      stop = now |> Timex.shift(seconds: 1) |> DateTime.truncate(:second)

      Repo.insert!(%Ping{
        start: now,
        stop: stop,
        project_id: id,
        status: status,
        message: message
      })

      unless is_nil(existing_ping) do
        Logger.info("Stopping existing ping interval")

        result =
          Ecto.Changeset.change(existing_ping, stop: now)
          |> Repo.update!()

        Logger.info("Updated old ping: #{inspect(result)}")
      end
    else
      Logger.info("Updating existing ping interval")

      changeset =
        Ecto.Changeset.change(existing_ping,
          stop: now,
          message: message
        )

      result = Repo.update!(changeset)
      Logger.info("Updated ping: #{inspect(result)}")
    end
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
      Logger.info("Checking #{project.name} with #{check_module}")
      result = check_module.check(project.params)
      Logger.info("Result: #{inspect(result)}")
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

  @doc """
  Import stuff based on the given graph.

  This function expects a valid `Dotx.graph/0`.

  It returns a list of created projects.
  """
  @spec import(Dotx.graph()) :: {:ok, []} | {:error, any()}
  def import(graph) do
    {nodes, graphs} = Dotx.to_nodes(graph)

    # Run this whole thing in a transaction.
    Repo.transaction(fn ->
      # Insert or find all projects, in a map of slug -> project.
      project_map =
        Map.new(nodes, fn {[id | _], node} ->
          # Check if we can find an existing node.
          {:ok, slug} = EctoFields.Slug.cast(id)

          project =
            case get_project_by_slug(id) do
              nil ->
                case create_project(%{"name" => id, "checker" => "unchecked", "params" => %{}}) do
                  {:ok, project} -> project
                  {:error, error} -> Repo.rollback(error)
                end

              project ->
                project
            end

          {id, project}
        end)

      all_ids_in_file = Enum.map(project_map, fn {_, %Project{id: id}} -> id end)

      # Insert all dependencies.
      Enum.each(nodes, fn {[id | _], node = %Dotx.Node{attrs: %{"edges_from" => edges}}} ->
        this_project = Map.get(project_map, id)

        dependencies =
          Enum.map(edges, fn %Dotx.Edge{to: %Dotx.Node{id: [to_id | _]}} ->
            Map.get(project_map, to_id)
          end)

        original_dependencies = this_project.dependencies

        # We also want to keep all dependencies that map to a node not in this file.
        deps_not_in_file =
          Enum.filter(original_dependencies, fn original_dep ->
            original_dep.id in all_ids_in_file
          end)

        dependencies = dependencies ++ deps_not_in_file

        change_project(this_project, %{"dependencies" => dependencies})
        |> Repo.update!()
      end)
    end)
  end

  def get_ping_id(%Ping{start: start, project_id: id}) do
    hex_internal_id =
      "#{DateTime.to_iso8601(start, :basic)}$#{id}"
      |> Base.encode16()
      |> String.to_integer(16)

    Hashids.new()
    |> Hashids.encode(hex_internal_id)
  end

  def get_ping!(id) do
    [date_string, id_string] =
      Hashids.new()
      |> Hashids.decode!(id)
      |> then(fn [decoded_id] -> Integer.to_string(decoded_id, 16) end)
      |> Base.decode16!()
      |> String.split("$")

    date = Timex.parse!(date_string, "{ISO:Basic}")
    Repo.get_by!(Ping, start: date, project_id: id_string) |> Repo.preload(:project)
  end
end
