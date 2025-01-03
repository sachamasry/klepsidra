defmodule KlepsidraWeb.TagLive.Show do
  use KlepsidraWeb, :live_view

  @moduledoc false

  import KlepsidraWeb.ButtonComponents
  alias Klepsidra.Categorisation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tag, Categorisation.get_tag!(id))}
  end

  @impl true
  def handle_info({KlepsidraWeb.TagLive.FormComponent, {:saved, _tag}}, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Tag"
  defp page_title(:edit), do: "Edit Tag"
end
