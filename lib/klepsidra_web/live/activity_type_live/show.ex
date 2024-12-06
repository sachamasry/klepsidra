defmodule KlepsidraWeb.ActivityTypeLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.TimeTracking

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:activity_type, TimeTracking.get_activity_type!(id))}
  end

  defp page_title(:show), do: "Show Activity type"
  defp page_title(:edit), do: "Edit Activity type"
end
