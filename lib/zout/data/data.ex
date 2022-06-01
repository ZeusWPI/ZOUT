defmodule Zout.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Zout.Repo

  alias Zout.Data.Project
  alias Zout.Data.Downtime
  alias Zout.Checker

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

  """
  def get_project!(id), do: raise("TODO")

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, ...}

  """
  def create_project(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, ...}

  """
  def update_project(%Project{} = project, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, ...}

  """
  def delete_project(%Project{} = project) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Todo{...}

  """
  def change_project(%Project{} = project, _attrs \\ %{}) do
    raise "TODO"
  end

  def list_projects_and_status do
    now = DateTime.utc_now()

    Project
    |> join(:left, [p], d in Downtime,
      on: p.id == d.project_id and d.start <= ^now and is_nil(d.end)
    )
    |> select([p, d], %{project: p, downtime: d})
    |> Repo.all()
  end

  defp handle_check_result(%Project{id: id}, :working) do
    existing =
      Downtime
      |> where([d], d.project_id == ^id and is_nil(d.end))
      |> Repo.one()

    if !is_nil(existing) do
      Ecto.Changeset.change(existing, end: DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update!()
    end
  end

  defp handle_check_result(%Project{id: id}, {status, _message}) do
    existing =
      Downtime
      |> where([d], d.project_id == ^id and is_nil(d.end))
      |> Repo.one()

    if is_nil(existing) do
      Repo.insert!(%Downtime{
        start: DateTime.utc_now() |> DateTime.truncate(:second),
        end: nil,
        project_id: id,
        status: status
      })
    else
      if existing.status != status do
        now = DateTime.utc_now() |> DateTime.truncate(:second)
        Ecto.Changeset.change(existing, end: now)
        |> Repo.update!()
        Repo.insert!(%Downtime{
          start: now,
          end: nil,
          project_id: id,
          status: status
        })
      end
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
      result = check_module.check(project.params)
      handle_check_result(project, result)
    end)
  end
end
