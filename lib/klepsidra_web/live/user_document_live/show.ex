defmodule KlepsidraWeb.UserDocumentLive.Show do
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
     |> assign(:user_document, Documents.get_user_document!(id))}
  end

  defp page_title(:show), do: "Show user document"
  defp page_title(:edit), do: "Edit user document"
end
