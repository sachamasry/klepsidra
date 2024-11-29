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
    document = Documents.get_user_document_with_all_fields(id)

    socket =
      socket
      |> assign(
        page_title: page_title(socket.assigns.live_action),
        user_document: document,
        user_name: document.user_name,
        document_type: document.document_type_name,
        document_issuer: document.document_issuer_name,
        issuing_country_name: document.country_name
      )

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show user document"
  defp page_title(:edit), do: "Edit user document"
end
