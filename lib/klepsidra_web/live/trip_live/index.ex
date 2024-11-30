defmodule KlepsidraWeb.TripLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Travel
  alias Klepsidra.Travel.Trip

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :trips, Travel.list_trips())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Trip")
    |> assign(:trip, Travel.get_trip!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Trip")
    |> assign(:trip, %Trip{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Trips")
    |> assign(:trip, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.TripLive.FormComponent, {:saved, trip}}, socket) do
    {:noreply, stream_insert(socket, :trips, trip)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    trip = Travel.get_trip!(id)
    {:ok, _} = Travel.delete_trip(trip)

    {:noreply, stream_delete(socket, :trips, trip)}
  end
end
