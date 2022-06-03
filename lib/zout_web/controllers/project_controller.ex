defmodule ZoutWeb.ProjectController do
  use ZoutWeb, :controller

  action_fallback ZoutWeb.FallbackController

  alias Zout.Data
  alias Zout.Data.Project
  alias ZoutWeb.Auth.Guardian

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_index, user)

    projects = Data.list_projects_and_status()
    render(conn, :index, projects: projects)
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_new, user)

    project = Data.change_project(%Project{})
    render(conn, "new.html", changeset: project)
  end

  def create(conn, %{"project" => params}) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_create, user, params)

    case Data.create_project(params) do
      {:ok, _project} ->
        conn
        |> put_status(:created)
        |> redirect(to: Routes.project_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    project = Data.get_project!(id)
    Bodyguard.permit!(Data.Policy, :project_edit, user, project)

    changeset = Data.change_project(project)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => params}) do
    user = Guardian.Plug.current_resource(conn)
    project = Data.get_project!(id)
    Bodyguard.permit!(Data.Policy, :project_update, user, project)

    case Data.update_project(project, params) do
      {:ok, _project} ->
        redirect(conn, to: Routes.project_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("edit.html", changeset: changeset)
    end
  end
end
