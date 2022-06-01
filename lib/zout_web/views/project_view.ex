defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data.Downtime

  def render_status(nil), do: "working"
  def render_status(%Downtime{status: :working}), do: "working"
  def render_status(%Downtime{status: status, start: start}), do: "#{status} since #{DateTime.to_iso8601(start)}"
end
