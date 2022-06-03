defmodule ZoutWeb.ProjectController do
  use ZoutWeb, :controller

  alias Zout.Data
  alias Zout.Data.Project

  def index(conn, _params) do
    projects = Data.list_projects_and_status()

    Data.check_all_projects()

    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    project = Data.change_project(%Project{})
    render(conn, "new.html", changeset: project)
  end

  def create(conn, %{"project" => params}) do
    case Data.create_project(params) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> redirect(to: Routes.project_path(conn, :index))

      {:error, changeset} ->
        IO.inspect(changeset)

        conn
        |> put_status(:unprocessable_entity)
        |> render("new.html", changeset: changeset)
    end
  end
end
