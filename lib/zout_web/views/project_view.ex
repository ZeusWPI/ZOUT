defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data.Downtime
  alias Zout.Checker
  alias ZoutWeb.FormatHelpers

  def number_of_days(since) do
    now = DateTime.utc_now()

    Timex.Interval.new(from: since, until: now)
    |> Timex.Interval.duration(:days)
  end

  def render_status(nil), do: "🟢 working"
  def render_status(%Downtime{status: :working}), do: "🟢 working"

  def render_status(%Downtime{status: :failing, start: start}) do
    days = number_of_days(start)
    "🟠 failing sinds #{FormatHelpers.human_datetime(start)} (#{days} dagen)"
  end

  def render_status(%Downtime{status: :offline, start: start}) do
    days = number_of_days(start)
    "🔴 offline sinds #{FormatHelpers.human_datetime(start)} (#{days} dagen)"
  end

  def render_help_for(checker) do
    module = Checker.checker(checker)
    {_, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(module)

    String.split(module_doc, "\n")
    |> Enum.at(0)
    |> Earmark.as_html!()
  end

  def from_map(changeset_struct, field) do
    actual_field = Atom.to_string(field) |> String.trim_leading("params_")

    params = Map.get(changeset_struct.data, :params, %{}) || %{}
    Map.get(params, actual_field)
  end

  defp json_status(nil), do: "working"
  defp json_status(%Downtime{status: status}), do: status

  def render("index.json", %{projects: projects}) do
    %{
      projects:
        Enum.map(projects, fn %{project: p, downtime: d} ->
          %{
            id: p.id,
            name: p.name,
            source: p.source,
            home: p.home,
            status: json_status(d),
            since: "TODO"
          }
        end),
      lastCheck: "TODO"
    }
  end

  def can?(conn, action, params \\ nil) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit?(Zout.Data.Policy, action, user, params)
  end
end
