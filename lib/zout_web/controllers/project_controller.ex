defmodule ZoutWeb.ProjectController do
  use ZoutWeb, :controller

  alias Zout.Data

  def index(conn, _params) do
    projects = Data.list_projects_and_status()

    Data.check_all_projects()

    render(conn, "index.html", projects: projects)
  end
end
