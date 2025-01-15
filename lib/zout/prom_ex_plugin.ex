defmodule Zout.PromExPlugin do
  use PromEx.Plugin

  @impl true
  def event_metrics(_opts) do
    [
      ping_status_event()
    ]
  end

  defp ping_status_event() do
    Event.build(
      :ping_status_event_metrics,
      [
        last_value(
          [:zout, :ping, :status],
          event_name: [:zout, :ping, :status],
          description: "The status of ping of a project",
          measurement: & &1.value,
          tags: [:project, :homepage],
          tag_values: &ping_status_tag_values/1
        )
      ]
    )
  end

  defp ping_status_tag_values(project) do
    %{
      project: project.name,
      homepage: project.home
    }
  end
end
