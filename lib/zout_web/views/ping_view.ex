defmodule ZoutWeb.PingView do
  use ZoutWeb, :view

  alias Zout.Data
  alias Zout.Data.Ping
  alias ZoutWeb.FormatHelpers
  alias ZoutWeb.ProjectView

  def title("show.html", %{ping: ping}) do
    "Ping #{Data.get_ping_id(ping)}"
  end

  def status_text(nil), do: "niet gecontroleerd"
  def status_text(%Ping{status: :unchecked}), do: "niet gecontroleerd"
  def status_text(%Ping{status: :working}), do: "werkend"
  def status_text(%Ping{status: :failing}), do: "problematisch"
  def status_text(%Ping{status: :offline}), do: "dood"

  def render_status(_, icon \\ true)

  def render_status(nil, icon) do
    prefix = if icon, do: "#{ProjectView.status_icon(nil)} ", else: ""
    "#{prefix}niet gecontroleerd"
  end

  def render_status(%Ping{status: :unchecked}, icon), do: render_status(nil, icon)

  def render_status(%Ping{start: start} = p, icon) do
    prefix = if icon, do: "#{ProjectView.status_icon(p)} ", else: ""
    status_t = status_text(p)
    days = ProjectView.number_of_days(start)
    "#{prefix}#{status_t} (al #{days} dagen)"
  end
end
