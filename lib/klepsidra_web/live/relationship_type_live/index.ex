defmodule KlepsidraWeb.RelationshipTypeLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.RelationshipType

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :knowledge_management_relationship_types,
       KnowledgeManagement.list_knowledge_management_relationship_types()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit relationship type")
    |> assign(:relationship_type, KnowledgeManagement.get_relationship_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New relationship type")
    |> assign(:relationship_type, %RelationshipType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Relationship types")
    |> assign(:relationship_type, nil)
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.RelationshipTypeLive.FormComponent, {:saved, relationship_type}},
        socket
      ) do
    {:noreply, stream_insert(socket, :knowledge_management_relationship_types, relationship_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    relationship_type = KnowledgeManagement.get_relationship_type!(id)
    {:ok, _} = KnowledgeManagement.delete_relationship_type(relationship_type)

    {:noreply,
     handle_deleted_relationship_type(
       socket,
       relationship_type,
       :knowledge_management_relationship_types
     )}
  end

  defp handle_deleted_relationship_type(socket, relationship_type, source_stream) do
    socket
    |> stream_delete(source_stream, relationship_type)
    |> put_toast(:info, "Relationship type deleted successfully")
  end
end
