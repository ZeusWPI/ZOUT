defmodule Zout.PromExPlugin do
  use PromEx.Plugin

  @impl true
  def event_metrics(_opts) do
    [
      project_status_event()
    ]
  end

  defp project_status_event() do
    Event.build(
      :project_status_event_metrics,
      [
        last_value(
          [:zout, :project, :status],
          event_name: [:zout, :project, :status],
          description: "The status of a project",
          measurement: & &1.value,
          tags: [:project, :homepage],
          tag_values: &project_status_tag_values/1
        )
      ]
    )
  end

  defp project_status_tag_values(project) do
    %{
      project: project.name,
      homepage: project.home
    }
  end
end
