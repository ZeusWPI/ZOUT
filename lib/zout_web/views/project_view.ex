defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data.Downtime

  def render_status(nil), do: "working"
  def render_status(%Downtime{status: :working}), do: "working"

  def render_status(%Downtime{status: status, start: start}),
    do: "#{status} since #{DateTime.to_iso8601(start)}"

  def is_down(nil), do: false
  def is_down(%Downtime{status: :working}), do: false
  def is_down(_), do: true
end
