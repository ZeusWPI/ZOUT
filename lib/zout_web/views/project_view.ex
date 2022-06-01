defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data.Downtime

  def render_status(nil), do: "working"
  def render_status(%Downtime{status: :working}), do: "working"
  def render_status(%Downtime{status: :failing}), do: "failing"
  def render_status(%Downtime{status: :offline}), do: "offline"
end
