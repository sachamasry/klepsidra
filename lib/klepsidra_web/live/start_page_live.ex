defmodule KlepsidraWeb.StartPageLive do
  @moduledoc """
  Klepsidra's home page, where every user is expected to start their
  interaction with the application.

  The 'today' view is available on this page, listing all the timers active
  today, as well as any other pertinent information for daily use.
  """

  use KlepsidraWeb, :live_view
  import LiveToast
  import KlepsidraWeb.AnnotationComponents
  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.DynamicCSS
  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units

  @impl true
  def mount(_params, _session, socket) do
    current_date_stamp = NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    current_datetime = NaiveDateTime.local_now()

    quote = Klepsidra.KnowledgeManagement.get_random_quote()

    open_timers = TimeTracking.list_all_open_timers(current_date_stamp)
    open_timer_count = TimeTracking.get_open_timer_count()
    today = format_date(get_current_datetime_stamp())

    matching_closed_timers =
      %{
        from: current_datetime,
        to: current_datetime,
        project_id: "",
        business_partner_id: "",
        activity_type_id: "",
        billable: "",
        modified: ""
      }
      |> TimeTracking.list_timers_with_statistics()

    closed_timers =
      matching_closed_timers.timer_list
      |> TimeTracking.format_timer_fields(current_date_stamp)

    # TimeTracking.list_closed_timers_for_date(current_date_stamp)
    closed_timer_count = matching_closed_timers.meta.timer_count
    # TimeTracking.get_closed_timer_count_for_date(current_date_stamp)

    aggregate_duration = matching_closed_timers.meta.aggregate_duration.base_unit_duration
    # get_aggregate_duration_for_date(current_date_stamp)
    human_readable_duration =
      matching_closed_timers.meta.aggregate_duration.human_readable_duration

    human_readable_billing_duration =
      matching_closed_timers.meta.aggregate_billing_duration.human_readable_duration

    # Timer.format_human_readable_duration(aggregate_duration, [
    #   :hour_increment,
    #   :minute_increment
    # ])

    closed_timer_message =
      "#{human_readable_duration} 
       #{if(human_readable_duration != "" and not is_nil(human_readable_duration),
      do: "timed",
      else: "")}
      #{closed_timer_count} #{if(closed_timer_count == 1, do: "activity", else: "activities")}
         timed today"

    aggregate_tag_list =
      current_date_stamp
      |> TimeTracking.list_all_timer_tags_for_date()
      |> DynamicCSS.generate_tag_styles()

    socket =
      socket
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :add,
        aggregate_tag_list
      )
      |> assign(:today, today)
      |> assign(
        quote: quote,
        aggregate_duration: aggregate_duration,
        human_readable_duration: human_readable_duration,
        human_readable_billing_duration: human_readable_billing_duration,
        open_timer_count: open_timer_count,
        closed_timer_count: closed_timer_count,
        closed_timer_statistics: closed_timer_message
      )
      |> stream(:open_timers, open_timers)
      |> stream(:closed_timers, closed_timers)

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
        String.to_existing_atom(billing_duration_unit)
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
  def handle_event("selection_recovery", _selection_from_client, socket), do: {:noreply, socket}

  @impl true
  def handle_event("delete-open-timer", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    socket =
      socket
      |> update(:open_timer_count, fn tc -> tc - 1 end)

    {:noreply, handle_deleted_timer(socket, timer, :open_timers)}
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

    {:noreply, handle_deleted_timer(socket, timer, :closed_timers)}
  end

  defp handle_started_timer(socket, timer) do
    socket
    |> stream_insert(:open_timers, timer, at: 0)
    |> update(:open_timer_count, fn tc -> tc + 1 end)
    |> put_toast(:info, "Timer started")
  end

  defp handle_open_timer(socket, timer) do
    socket
    |> stream_insert(:open_timers, timer)
    |> update(:open_timer_count, fn tc -> tc + 1 end)
    |> put_toast(:info, "Timer created successfully")
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
    |> stream_delete(:open_timers, timer)
    |> update(:open_timer_count, fn tc -> tc - 1 end)
    |> stream_insert(:closed_timers, timer, at: 0)
    |> update(:closed_timer_count, fn tc -> tc + 1 end)
    |> put_toast(:info, "Timer stopped")
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
    |> stream_insert(:open_timers, timer)
    |> update(:open_timer_count, fn tc -> tc + 1 end)
  end

  defp handle_updated_timer_changes(socket, timer, {:closed, :closed}) do
    socket
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
    |> update(:open_timer_count, fn tc -> tc - 1 end)
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
    |> update(:closed_timer_count, fn tc -> tc - 1 end)
    |> stream_insert(:open_timers, timer, at: 0)
    |> update(:open_timer_count, fn tc -> tc + 1 end)
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

  defp handle_deleted_timer(socket, timer, source_stream) do
    socket
    |> stream_delete(source_stream, timer)
    |> put_toast(:info, "Timer deleted successfully")
  end

  defp handle_saved_note(socket, _note) do
    socket
    |> put_toast(:info, "Note created successfully")
  end

  @spec get_current_datetime_stamp() :: NaiveDateTime.t()
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

  @spec format_date(datetime_stamp :: NaiveDateTime.t()) :: binary()
  defp format_date(datetime_stamp) do
    case Timer.format_human_readable_date(datetime_stamp) do
      {:ok, formatted_date} -> formatted_date
      _ -> ""
    end
  end

  # defp get_aggregate_duration_for_date(date_stamp) do
  #   date_stamp
  #   |> Klepsidra.TimeTracking.get_closed_timer_durations_for_date()
  #   |> Timer.convert_durations_to_base_time_unit()
  #   |> Timer.sum_base_unit_durations()
  # end

  attr :tag, :map, default: []

  def display_tags(assigns) do
    ~H"""
    <div
      class={"tag-#{DynamicCSS.convert_tag_name_to_class(@tag["name"])} rounded-full basis-4 h-4"}
      title={"#{@tag["name"]}"}
    >
    </div>
    """
  end
end
