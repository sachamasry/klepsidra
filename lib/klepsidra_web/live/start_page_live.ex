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
      |> stream(:timers, TimeTracking.get_timers_for_date(current_datetime_stamp))

    {:ok, socket}
  end
end
