defmodule KlepsidraWeb.TripLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Travel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    trip = Travel.get_trip_with_user_and_country(id)
    trip_struct = Travel.get_trip!(id)

    trip_title =
      case trip.description do
        "" -> "Trip to #{trip.country_name}"
        description -> description
      end

    socket =
      socket
      |> assign(
        page_title: page_title(socket.assigns.live_action),
        trip: trip,
        trip_struct: trip_struct,
        trip_title: trip_title,
        user_name: trip.user_name,
        country_name: trip.country_name
      )

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show trip"
  defp page_title(:edit), do: "Edit trip"
end
