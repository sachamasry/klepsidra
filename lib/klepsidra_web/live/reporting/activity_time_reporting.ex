defmodule KlepsidraWeb.TimerLive.ActivityTimeReporting do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast
  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.TimeTracking

  @impl true
  def mount(_params, _session, socket) do
    filter = %{
      from: "",
      to: "",
      project_id: "",
      business_partner_id: "",
      activity_type_id: "",
      billable: "",
      modified: ""
    }

    projects = Klepsidra.Projects.list_active_projects()
    customers = Klepsidra.BusinessPartners.list_active_customers()
    activity_types = Klepsidra.TimeTracking.list_active_activity_types()
    filtered_timers = TimeTracking.list_timers_with_statistics(filter)

    {:ok,
     socket
     |> assign(
       display_help: false,
       filter: filter,
       projects: projects,
       customers: customers,
       activity_types: activity_types,
       timer_count: filtered_timers.meta.timer_count,
       aggregate_duration: filtered_timers.meta.aggregate_duration,
       average_duration: filtered_timers.meta.average_timer_duration,
       aggregate_billing_duration: filtered_timers.meta.aggregate_billing_duration
     )
     |> stream(:timers, filtered_timers.timer_list)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_timer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Timer")
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Activity Timers")
    |> assign(:timer, nil)
  end

  defp apply_action(socket, :new_note, %{"id" => id} = _params) do
    socket
    |> assign(:page_title, "New note")
    |> assign(:timer_id, id)
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved_open_timer, timer}}, socket) do
    {:noreply, handle_open_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved_closed_timer, timer}}, socket) do
    {:noreply, handle_closed_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:updated_open_timer, timer}}, socket) do
    {:noreply, handle_updated_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:updated_closed_timer, timer}}, socket) do
    {:noreply, handle_updated_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:timer_started, timer}}, socket) do
    {:noreply, handle_started_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:timer_stopped, timer}}, socket) do
    {:noreply, handle_closed_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, note}}, socket) do
    {:noreply, handle_saved_note(socket, note)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    {:noreply, handle_deleted_timer(socket, timer, :timers)}
  end

  @impl true
  def handle_event(
        "filter",
        %{
          "from" => from,
          "to" => to,
          "project_id" => project_id,
          "business_partner_id" => business_partner_id,
          "activity_type_id" => activity_type_id,
          "billable" => billable,
          "modified" => modified
        },
        socket
      ) do
    from = parse_date(from)
    to = parse_date(to)

    filter = %{
      from: from,
      to: to,
      project_id: project_id,
      business_partner_id: business_partner_id,
      activity_type_id: activity_type_id,
      billable: billable,
      modified: modified
    }

    filtered_timers = TimeTracking.list_timers_with_statistics(filter)

    socket =
      socket
      |> assign(
        filter: filter,
        timer_count: filtered_timers.meta.timer_count,
        aggregate_duration: filtered_timers.meta.aggregate_duration,
        average_duration: filtered_timers.meta.average_timer_duration,
        aggregate_billing_duration: filtered_timers.meta.aggregate_billing_duration
      )
      |> stream(:timers, filtered_timers.timer_list, reset: true)

    {:noreply, socket}
  end

  defp handle_started_timer(socket, timer) do
    socket
    |> stream_insert(:timers, timer, at: 0)
    |> put_toast(:info, "Timer started")
  end

  defp handle_open_timer(socket, timer) do
    socket
    |> stream_insert(:timers, timer)
    |> put_toast(:info, "Timer created successfully")
  end

  defp handle_closed_timer(socket, timer) do
    socket
    |> stream_insert(:timers, timer)
    |> put_toast(:info, "Timer stopped")
  end

  defp handle_updated_timer(socket, timer) do
    socket
    |> stream_insert(:timers, timer)
    |> put_toast(:info, "Timer updated successfully")
  end

  defp handle_deleted_timer(socket, timer, source_stream) do
    socket
    |> stream_delete(source_stream, timer)
    |> put_toast(:info, "Timer deleted successfully")
  end

  defp handle_saved_note(socket, _note) do
    socket
    |> put_toast(:info, "Note created successfully")
  end

  defp parse_date(""), do: ""

  defp parse_date(date) when is_bitstring(date) do
    Timex.parse!(date, "{YYYY}-{0M}-{D}") |> NaiveDateTime.to_string()
  end
end
