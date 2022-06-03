defmodule ZoutWeb.PageController do
  use ZoutWeb, :controller

  def index(conn, _params) do
    # TODO, do something useful here.
    redirect(conn, to: Routes.project_path(conn, :index))
  end
end
