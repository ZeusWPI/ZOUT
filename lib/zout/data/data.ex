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
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.
  """
  def create_project(attrs \\ %{}) do
    change_project(%Project{}, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.
  """
  def update_project(%Project{} = project, attrs) do
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
  List all projects, but get the active downtime for each.
  """
  def list_projects_and_status do
    now = DateTime.utc_now()

    Project
    |> where(deleted: false)
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
