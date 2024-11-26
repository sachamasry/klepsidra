defmodule KlepsidraWeb.DocumentIssuerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

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
     |> assign(:document_issuer, Documents.get_document_issuer!(id))}
  end

  defp page_title(:show), do: "Show Document issuer"
  defp page_title(:edit), do: "Edit Document issuer"
end
