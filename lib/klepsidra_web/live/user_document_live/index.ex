defmodule KlepsidraWeb.UserDocumentLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.Documents
  alias Klepsidra.Documents.UserDocument

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(
        :user_documents,
        Documents.list_user_documents_with_document_type_issuer_and_country()
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit user document")
    |> assign(:user_document, Documents.get_user_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New user document")
    |> assign(:user_document, %UserDocument{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "User documents")
    |> assign(:user_document, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.UserDocumentLive.FormComponent, {:saved, user_document}}, socket) do
    {:noreply, stream_insert(socket, :user_documents, user_document)}
  end

  @impl true
  def handle_event("selection_recovery", _selection_from_client, socket), do: {:noreply, socket}

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_document = Documents.get_user_document!(id)
    {:ok, _} = Documents.delete_user_document(user_document)

    {:noreply, handle_deleted_user_document(socket, user_document, :user_documents)}
  end

  defp handle_deleted_user_document(socket, user_document, source_stream) do
    socket
    |> stream_delete(source_stream, user_document)
    |> put_toast(:info, "User document deleted successfully")
  end
end
