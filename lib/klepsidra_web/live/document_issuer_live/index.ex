defmodule KlepsidraWeb.DocumentIssuerLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.Documents
  alias Klepsidra.Documents.DocumentIssuer

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:document_issuers, Documents.list_document_issuers_with_country())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit document issuer")
    |> assign(:document_issuer, Documents.get_document_issuer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New document issuer")
    |> assign(:document_issuer, %DocumentIssuer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Document issuers")
    |> assign(:document_issuer, nil)
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.DocumentIssuerLive.FormComponent, {:saved, document_issuer}},
        socket
      ) do
    {:noreply, stream_insert(socket, :document_issuers, document_issuer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document_issuer = Documents.get_document_issuer!(id)
    {:ok, _} = Documents.delete_document_issuer(document_issuer)

    {:noreply, handle_deleted_document_issuer(socket, document_issuer, :document_issuers)}
  end

  defp handle_deleted_document_issuer(socket, document_type, source_stream) do
    socket
    |> stream_delete(source_stream, document_type)
    |> put_toast(:info, "Document issuer deleted successfully")
  end
end
