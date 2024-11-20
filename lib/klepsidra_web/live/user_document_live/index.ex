defmodule KlepsidraWeb.UserDocumentLive.Index do
  use KlepsidraWeb, :live_view

  alias Klepsidra.Documents
  alias Klepsidra.Documents.UserDocument

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :user_documents, Documents.list_user_documents())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User document")
    |> assign(:user_document, Documents.get_user_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User document")
    |> assign(:user_document, %UserDocument{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing User documents")
    |> assign(:user_document, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.UserDocumentLive.FormComponent, {:saved, user_document}}, socket) do
    {:noreply, stream_insert(socket, :user_documents, user_document)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_document = Documents.get_user_document!(id)
    {:ok, _} = Documents.delete_user_document(user_document)

    {:noreply, stream_delete(socket, :user_documents, user_document)}
  end
end
