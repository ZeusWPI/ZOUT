defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data
  alias Zout.Data.Project
  alias Zout.Data.Ping
  alias Zout.Data.Dependency
  alias Zout.Checker
  alias ZoutWeb.FormatHelpers

  def number_of_days(nil) do
    now = DateTime.utc_now()

    Timex.Interval.new(from: now, until: [minutes: 1])
    |> Timex.Interval.duration(:days)
  end

  def number_of_days(since) do
    now = DateTime.utc_now()

    Timex.Interval.new(from: since, until: now)
    |> Timex.Interval.duration(:days)
  end

  def status_colour(nil), do: "#2e7d32"
  def status_colour(%Ping{status: :working}), do: "#2e7d32"
  def status_colour(%Ping{status: :failing}), do: "#ff8f00"
  def status_colour(%Ping{status: :offline}), do: "#c62828"
  def status_colour(%Ping{status: :unchecked}), do: "#d3d3d3"

  def text_colour(nil), do: "white"
  def text_colour(%Ping{status: :working}), do: "white"
  def text_colour(%Ping{status: :failing}), do: "black"
  def text_colour(%Ping{status: :offline}), do: "white"
  def text_colour(%Ping{status: :unchecked}), do: "black"

  def status_icon(nil), do: "⚪"
  def status_icon(%Ping{status: :working}), do: "🟢"
  def status_icon(%Ping{status: :failing}), do: "🟠"
  def status_icon(%Ping{status: :offline}), do: "🔴"
  def status_icon(%Ping{status: :unchecked}), do: "⚪"

  def render_status(_, icon \\ true)

  def render_status(nil, icon) do
    prefix = if icon, do: "#{status_icon(nil)} ", else: ""
    "#{prefix}niet gecontroleerd"
  end

  def render_status(%Ping{status: :unchecked}, icon), do: render_status(nil, icon)

  def render_status(%Ping{status: :working, start: start} = p, icon) do
    prefix = if icon, do: "#{status_icon(p)} ", else: ""
    days = number_of_days(start)
    "#{prefix}working sinds #{FormatHelpers.human_datetime(start)} (#{days} dagen)"
  end

  def render_status(%Ping{status: :failing, start: start} = p, icon) do
    prefix = if icon, do: "#{status_icon(p)} ", else: ""
    days = number_of_days(start)
    "#{prefix}failing sinds #{FormatHelpers.human_datetime(start)} (#{days} dagen)"
  end

  def render_status(%Ping{status: :offline, start: start} = p, icon) do
    prefix = if icon, do: "#{status_icon(p)} ", else: ""
    days = number_of_days(start)
    "#{prefix}offline sinds #{FormatHelpers.human_datetime(start)} (#{days} dagen)"
  end

  def last_checked(data) do
    Enum.map(data, fn
      %{ping: %Ping{stop: s}} -> s
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.max(NaiveDateTime, fn -> Timex.now() end)
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

  defp json_status(nil), do: nil
  defp json_status(%Ping{status: status}), do: status

  defp json_start_ping(nil), do: nil
  defp json_start_ping(%{start: nil}), do: nil
  defp json_start_ping(%{start: s}), do: NaiveDateTime.to_iso8601(s)

  defp json_stop_ping(nil), do: nil
  defp json_stop_ping(%{stop: nil}), do: nil
  defp json_stop_ping(%{stop: s}), do: NaiveDateTime.to_iso8601(s)

  def render("index.json", %{projects_and_pings: projects, dependencies: dependencies}) do
    last_check = last_checked(projects)

    %{
      projects:
        Enum.map(projects, fn %{project: p, ping: c} ->
          %{
            id: p.id,
            name: p.name,
            source: p.source,
            home: p.home,
            status: json_status(c),
            start: json_start_ping(c),
            stop: json_stop_ping(c),
            dependencies: Map.get(dependencies, p.id, [])
          }
        end),
      lastCheck: NaiveDateTime.to_iso8601(last_check)
    }
  end

  def can?(conn, action, params \\ nil) do
    user = Guardian.Plug.current_resource(conn)
    Bodyguard.permit?(Zout.Data.Policy, action, user, params)
  end

  def title("index.html", _assigns) do
    "Alle projecten"
  end

  def title("show.html", %{project: project}) do
    project.name
  end

  def title("new.html", _assigns) do
    "Nieuw project"
  end

  def title("edit.html", %{changeset: changeset}) do
    "#{changeset.data.name} bewerken"
  end

  def title(_, _), do: ""

  @doc """
  Check if the second project is a dependency of the first.
  """
  def dependency?(%Project{dependencies: deps}, %Project{id: id}) do
    Enum.any?(deps, fn p -> p.id == id end)
  end
end
