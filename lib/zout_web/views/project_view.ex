defmodule ZoutWeb.ProjectView do
  use ZoutWeb, :view

  alias Zout.Data.Downtime
  alias Zout.Checker

  def render_status(nil), do: "working"
  def render_status(%Downtime{status: :working}), do: "working"

  def render_status(%Downtime{status: status, start: start}),
    do: "#{status} since #{DateTime.to_iso8601(start)}"

  def render_help_for(checker) do
    module = Checker.checker(checker)
    {_, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(module)

    String.split(module_doc, "\n")
    |> Enum.at(0)
    |> Earmark.as_html!()
  end

  def from_map(changeset_struct, field) do
    actual_field = Atom.to_string(field) |> String.trim_leading("params_")

    changeset_struct.data
    |> Map.get(:params, %{})
    |> Map.get(actual_field)
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
end
