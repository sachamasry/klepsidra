defmodule KlepsidraWeb.DocumentTypeLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast

  alias Klepsidra.Documents
  alias Klepsidra.Documents.DocumentType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :document_types, Documents.list_document_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit document type")
    |> assign(:document_type, Documents.get_document_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New document type")
    |> assign(:document_type, %DocumentType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing document types")
    |> assign(:document_type, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.DocumentTypeLive.FormComponent, {:saved, document_type}}, socket) do
    {:noreply, stream_insert(socket, :document_types, document_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    document_type = Documents.get_document_type!(id)
    {:ok, _} = Documents.delete_document_type(document_type)

    {:noreply, handle_deleted_document_type(socket, document_type, :document_types)}
  end

  defp handle_deleted_document_type(socket, document_type, source_stream) do
    socket
    |> stream_delete(source_stream, document_type)
    |> put_toast(:info, "Document type deleted successfully")
  end
end
