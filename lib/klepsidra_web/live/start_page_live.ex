defmodule KlepsidraWeb.StartPageLive do
  @moduledoc """
  Klepsidra's home page, where every user is expected to start their
  interaction with the application.

  The 'today' view is available on this page, listing all the timers active
  today, as well as any other pertinent information for daily use.
  """

  use KlepsidraWeb, :live_view
  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units

  @impl true
  def mount(_params, _session, socket) do
    current_datetime_stamp =
      Timer.get_current_timestamp()
      |> NaiveDateTime.beginning_of_day()

    formatted_current_date =
      Klepsidra.Cldr.DateTime.to_string(current_datetime_stamp, format: "EEEE, dd MMM YYYY")

    today =
      case formatted_current_date do
        {:ok, today} -> today
        _ -> ""
      end

    aggregate_duration =
      case Timer.get_aggregate_duration(
             TimeTracking.get_timers_for_date(current_datetime_stamp),
             :sixty_minute_increment
           ) do
        {:ok, duration} -> duration
        _ -> ""
      end

    socket =
      socket
      |> assign(today: today)
      |> assign(aggregate_duration: aggregate_duration)
      |> stream(:open_timers, TimeTracking.get_all_open_timers())
      |> stream(:closed_timers, TimeTracking.get_timers_for_date(current_datetime_stamp))

    {:ok, socket}
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

  defp apply_action(socket, nil, _params), do: socket

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :open_timers, timer)}
    # {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :open_timers, timer)}
    # {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, _note}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    # {:noreply, stream_delete(socket, :open_timers, timer)}
    {:noreply, socket}
  end
end
