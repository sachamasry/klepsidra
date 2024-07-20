defmodule KlepsidraWeb.TimerLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.TimeTracking
  import LiveToast
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units
  alias KlepsidraWeb.Live.NoteLive.NoteFormComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(display_help: false)
     |> stream(:timers, TimeTracking.list_timers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_timer, _params) do
    socket
    |> assign(:page_title, "Manual Timer")
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :edit_timer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Timer")
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :start_timer, _params) do
    billing_duration_unit = Units.get_default_billing_increment()

    socket
    |> assign(:page_title, "Starting Timer")
    |> assign(
      duration_unit: "minute",
      billing_duration_unit: billing_duration_unit
    )
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :stop_timer, %{"id" => id}) do
    start_timestamp = TimeTracking.get_timer!(id).start_stamp
    clocked_out = Timer.clock_out(start_timestamp, :minute)
    billing_duration_unit = Units.get_default_billing_increment()

    billing_duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        clocked_out.end_timestamp,
        String.to_atom(billing_duration_unit)
      )

    socket
    |> assign(:page_title, "Clock out")
    |> assign(
      clocked_out: clocked_out,
      duration_unit: "minute",
      billing_duration: billing_duration,
      billing_duration_unit: billing_duration_unit
    )
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
  # def handle_event("keyboard_event", %{"key" => "s"} = _params, socket) do
  #   {:noreply,
  #    assign(socket,
  #      live_action: :start,
  #      page_title: "Starting Timer",
  #      start_timestamp:
  #        Timer.get_current_timestamp()
  #        |> Timer.convert_naivedatetime_to_html!(),
  #      timer: %Timer{}
  #    )}
  # end

  # def handle_event("keyboard_event", %{"key" => "?"} = _params, socket) do
  #   {:noreply,
  #    assign(socket,
  #      display_help: true
  #    )}
  # end

  def handle_event("keyboard_event", _params, socket) do
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
end
