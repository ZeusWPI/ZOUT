defmodule ZoutWeb.ImportController do
  use ZoutWeb, :controller

  action_fallback ZoutWeb.FallbackController

  alias Zout.Data
  alias ZoutWeb.Auth.Guardian

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit!(Data.Policy, :project_import, user)

    render(conn, :index, params)
  end

  def import(conn, %{"import" => import} = params) do
    contents = import["contents"]
    # TODO: handle bad contents
    graph = Dotx.decode!(contents)

    case Data.import(graph) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Import geslaagd.")
        |> redirect(to: Routes.project_path(conn, :index))

      {:error, e} ->
        conn
        |> put_flash(:info, "Failure: #{IO.inspect(e)}")
        |> render(:index, params)
    end
  end
end
