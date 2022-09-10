defmodule ZoutWeb.PingView do
  use ZoutWeb, :view

  alias Zout.Data
  alias ZoutWeb.FormatHelpers

  def title("show.html", %{ping: ping}) do
    "Ping #{Data.get_ping_id(ping)}"
  end
end
