defmodule KlepsidraWeb.TimerLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.TimeTracking
  # alias Klepsidra.TimeTracking.Note
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

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit")
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :stop, %{"id" => id}) do
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

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Manual Timer")
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :new_note, %{"id" => id} = _params) do
    socket
    |> assign(:page_title, "New note")
    |> assign(:timer_id, id)
  end

  defp apply_action(socket, :start, _params) do
    socket
    |> assign(:page_title, "Starting Timer")
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Activity Timers")
    |> assign(:timer, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :timers, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :timers, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, _note}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    {:noreply, stream_delete(socket, :timers, timer)}
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
end
