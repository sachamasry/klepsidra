defmodule KlepsidraWeb.DocumentTypeLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:document_type, Documents.get_document_type!(id))}
  end

  defp page_title(:show), do: "Show document type"
  defp page_title(:edit), do: "Edit document type"
end
