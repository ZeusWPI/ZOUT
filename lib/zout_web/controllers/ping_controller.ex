defmodule ZoutWeb.PingController do
  use ZoutWeb, :controller

  action_fallback ZoutWeb.FallbackController

  alias Zout.Data
  alias ZoutWeb.Auth.Guardian

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    ping = Data.get_ping!(id)

    Bodyguard.permit!(Data.Policy, :ping_show, user, ping)

    render(conn, :show, ping: ping)
  end
end
