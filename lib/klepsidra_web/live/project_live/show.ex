defmodule KlepsidraWeb.ProjectLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Projects
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.Cldr.Unit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    aggregate_project_duration =
      get_aggregate_duration_for_project(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:project, Projects.get_project!(id))
      |> assign(
        aggregate_project_duration: aggregate_project_duration.base_unit_duration,
        duration_in_hours: aggregate_project_duration.duration_in_hours,
        human_readable_duration: aggregate_project_duration.human_readable_duration
      )

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"

  defp get_aggregate_duration_for_project(project_id) do
    project_id
    |> Klepsidra.TimeTracking.get_closed_timer_durations_for_project()
    |> Timer.convert_durations_to_base_time_unit()
    |> Timer.sum_base_unit_durations()
    |> format_aggregate_duration_for_project()
  end

  defp format_aggregate_duration_for_project(base_unit_duration) do
    %{
      base_unit_duration: base_unit_duration,
      duration_in_hours:
        base_unit_duration
        |> Unit.convert!(:hour)
        |> then(fn i -> Cldr.Unit.round(i, 1) end)
        |> Unit.to_string!(),
      human_readable_duration:
        Timer.format_human_readable_duration(base_unit_duration, [
          :day,
          :hour_increment
        ])
    }
  end
end
