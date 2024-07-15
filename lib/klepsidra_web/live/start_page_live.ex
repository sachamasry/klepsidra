defmodule KlepsidraWeb.StartPageLive do
  @moduledoc """
  Klepsidra's home page, where every user is expected to start their
  interaction with the application.

  The 'today' view is available on this page, listing all the timers active
  today, as well as any other pertinent information for daily use.
  """

  use KlepsidraWeb, :live_view
  import LiveToast
  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units

  @impl true
  def mount(_params, _session, socket) do
    current_datetime_stamp = get_current_datetime_stamp()
    aggregate_duration = get_aggregate_duration_for_date(current_datetime_stamp)
    human_readable_duration = Timer.format_human_readable_duration(aggregate_duration)
    closed_timer_count = TimeTracking.get_closed_timer_count_for_date(current_datetime_stamp)

    socket =
      socket
      |> assign(
        today: format_date(current_datetime_stamp),
        aggregate_duration: aggregate_duration,
        human_readable_duration: human_readable_duration,
        closed_timer_count: closed_timer_count
      )
      |> stream(:open_timers, TimeTracking.get_all_open_timers())
      |> stream(:closed_timers, TimeTracking.get_closed_timers_for_date(current_datetime_stamp))

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

  defp apply_action(socket, :show_timer, _params) do
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
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:timer_stopped, timer}}, socket) do
    {:noreply, handle_closed_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, _note}}, socket) do
    {:noreply, socket}
  end

  defp handle_open_timer(socket, timer) do
    socket
    |> stream_insert(:open_timers, timer)
  end

  defp handle_closed_timer(socket, timer) do
    closed_timer_duration = {timer.duration, timer.duration_time_unit}

    socket
    |> update(
      :aggregate_duration,
      fn aggregate_duration ->
        update_aggregate_duration(:summation, aggregate_duration, closed_timer_duration)
      end
    )
    |> update(:human_readable_duration, fn _human_readable_duration, assigns ->
      update_human_readable_duration(assigns.aggregate_duration)
    end)
    |> update(:closed_timer_count, fn tc -> tc + 1 end)
    |> put_toast(:info, "Timer stopped successfully")
    |> stream_delete(:open_timers, timer)
    |> stream_insert(:closed_timers, timer, at: 0)
  end

  defp handle_updated_timer(socket, timer) do
    previous_start_stamp = socket.assigns.timer.start_stamp
    previous_end_stamp = socket.assigns.timer.end_stamp
    current_start_stamp = timer.start_stamp
    current_end_stamp = timer.end_stamp

    previous_timer_status =
      if previous_start_stamp != "" && previous_end_stamp != "" && not is_nil(previous_end_stamp) do
        :closed
      else
        :open
      end

    current_timer_status =
      if current_start_stamp != "" && current_end_stamp != "" && not is_nil(current_end_stamp) do
        :closed
      else
        :open
      end

    socket
    |> handle_updated_timer_changes(timer, {previous_timer_status, current_timer_status})
    |> update(:human_readable_duration, fn _human_readable_duration, assigns ->
      update_human_readable_duration(assigns.aggregate_duration)
    end)
    |> put_toast(:info, "Timer updated successfully")
  end

  defp handle_updated_timer_changes(socket, timer, {:open, :open}) do
    socket
    |> stream_delete(:open_timers, timer)
    |> stream_insert(:open_timers, timer)
  end

  defp handle_updated_timer_changes(socket, timer, {:closed, :closed}) do
    socket
    |> stream_delete(:closed_timers, timer)
    |> stream_insert(:closed_timers, timer)
    |> update(
      :aggregate_duration,
      fn aggregate_duration ->
        update_aggregate_duration(
          :subtraction,
          aggregate_duration,
          {socket.assigns.timer.duration, socket.assigns.timer.duration_time_unit}
        )
      end
    )
    |> update(
      :aggregate_duration,
      fn aggregate_duration ->
        update_aggregate_duration(
          :summation,
          aggregate_duration,
          {timer.duration, timer.duration_time_unit}
        )
      end
    )
  end

  defp handle_updated_timer_changes(socket, timer, {:open, :closed}) do
    socket
    |> stream_delete(:open_timers, timer)
    |> stream_insert(:closed_timers, timer)
    |> update(:closed_timer_count, fn tc -> tc + 1 end)
    |> update(:aggregate_duration, fn aggregate_duration ->
      update_aggregate_duration(
        :summation,
        aggregate_duration,
        {timer.duration, timer.duration_time_unit}
      )
    end)
  end

  defp handle_updated_timer_changes(socket, timer, {:closed, :open}) do
    socket
    |> stream_delete(:closed_timers, timer)
    |> stream_insert(:open_timers, timer)
    |> update(:closed_timer_count, fn tc -> tc - 1 end)
    |> update(
      :aggregate_duration,
      fn aggregate_duration ->
        update_aggregate_duration(
          :subtraction,
          aggregate_duration,
          {socket.assigns.timer.duration, socket.assigns.timer.duration_time_unit}
        )
      end
    )
  end

  @impl true
  def handle_event("delete-open-timer", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    {:noreply, stream_delete(socket, :open_timers, timer)}
  end

  @impl true
  def handle_event("delete-closed-timer", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    deleted_timer_duration = {timer.duration, timer.duration_time_unit}
    {:ok, _} = TimeTracking.delete_timer(timer)

    socket =
      socket
      |> update(
        :aggregate_duration,
        fn aggregate_duration ->
          update_aggregate_duration(:subtraction, aggregate_duration, deleted_timer_duration)
        end
      )
      |> update(:human_readable_duration, fn _human_readable_duration, assigns ->
        update_human_readable_duration(assigns.aggregate_duration)
      end)
      |> update(:closed_timer_count, fn tc -> tc - 1 end)

    {:noreply, stream_delete(socket, :closed_timers, timer)}
  end

  defp get_current_datetime_stamp() do
    Timer.get_current_timestamp()
    |> NaiveDateTime.beginning_of_day()
  end

  defp update_aggregate_duration(:summation, starting_aggregate_duration, new_timer_duration) do
    durations_list =
      [starting_aggregate_duration, Timer.convert_duration_to_base_time_unit(new_timer_duration)]

    Timer.sum_base_unit_durations(durations_list)
  end

  defp update_aggregate_duration(
         :subtraction,
         starting_aggregate_duration,
         deleted_timer_duration
       ) do
    Timer.subtract_base_unit_durations(
      starting_aggregate_duration,
      Timer.convert_duration_to_base_time_unit(deleted_timer_duration)
    )
  end

  defp update_human_readable_duration(new_aggregate_duration) do
    Timer.format_human_readable_duration(new_aggregate_duration)
  end

  defp format_date(datetime_stamp) do
    case Timer.format_human_readable_date(datetime_stamp) do
      {:ok, formatted_date} -> formatted_date
      _ -> ""
    end
  end

  defp get_aggregate_duration_for_date(datetime_stamp) do
    datetime_stamp
    |> Klepsidra.TimeTracking.get_closed_timer_durations_for_date()
    |> Timer.convert_durations_to_base_time_unit()
    |> Timer.sum_base_unit_durations()
  end
end
