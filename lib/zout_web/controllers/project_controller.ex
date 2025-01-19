defmodule ZoutWeb.ProjectController do
  use ZoutWeb, :controller

  action_fallback ZoutWeb.FallbackController

  alias Zout.Data
  alias Zout.Data.Project
  alias ZoutWeb.Auth.Guardian

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_index, user)

    params =
      case get_format(conn) do
        "html" ->
          case Map.get(params, "format") do
            v when v in [nil, "table"] ->
              projects_and_pings = Data.list_projects_and_status()
              [format: :table, projects_and_pings: projects_and_pings]

            "avail" ->
              projects_and_pings =
                Data.all_recent_pings(months: -6)
                |> Enum.group_by(fn %{project: p} -> p end, fn %{ping: p} -> p end)

              [format: :avail, projects_and_pings: projects_and_pings]

            "graph" ->
              engine = Map.get(params, "engine", "elk")
              projects_and_pings = Data.list_projects_and_status()
              dependencies = Data.list_dependencies(projects_and_pings)

              [
                format: :graph,
                projects_and_pings: projects_and_pings,
                dependencies: dependencies,
                engine: engine
              ]
          end

        "json" ->
          projects_and_pings = Data.list_projects_and_status()

          dependencies =
            Data.list_dependencies(projects_and_pings)
            |> Enum.group_by(fn dep -> dep.from_id end, fn dep -> dep.to_id end)

          [projects_and_pings: projects_and_pings, dependencies: dependencies]
      end

    render(conn, :index, params)
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_new, user)

    project = Data.change_project(%Project{dependencies: []})
    projects = Data.list_projects()
    render(conn, "new.html", changeset: project, projects: projects)
  end

  def create(conn, %{"project" => params}) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_create, user, params)

    case Data.create_project(params) do
      {:ok, _project} ->
        conn
        |> redirect(to: ~p"/projects")

      {:error, changeset} ->
        projects = Data.list_projects()

        conn
        |> put_status(:unprocessable_entity)
        |> render("new.html", changeset: changeset, projects: projects)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    project = Data.get_project!(id)
    Bodyguard.permit!(Data.Policy, :project_edit, user, project)

    projects = Data.list_projects()
    changeset = Data.change_project(project)
    render(conn, "edit.html", changeset: changeset, projects: projects)
  end

  def update(conn, %{"id" => id, "project" => params}) do
    user = Guardian.Plug.current_resource(conn)
    project = Data.get_project!(id)
    Bodyguard.permit!(Data.Policy, :project_update, user, project)

    case Data.update_project(project, params) do
      {:ok, project} ->
        redirect(conn, to: ~p"/projects/#{project}")

      {:error, changeset} ->
        projects = Data.list_projects()

        conn
        |> put_status(:unprocessable_entity)
        |> render("edit.html", changeset: changeset, projects: projects)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    project = Data.get_project!(id)
    Bodyguard.permit!(Data.Policy, :project_show, user, project)

    historical_data =
      Data.recent_pings(project, months: -6)
      |> Enum.reverse()

    render(conn, :show, project: project, historical_data: historical_data)
  end
end
