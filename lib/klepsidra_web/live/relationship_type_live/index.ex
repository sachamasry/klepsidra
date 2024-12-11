defmodule KlepsidraWeb.RelationshipTypeLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

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
    |> assign(:page_title, "Edit Relationship type")
    |> assign(:relationship_type, KnowledgeManagement.get_relationship_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Relationship type")
    |> assign(:relationship_type, %RelationshipType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Knowledge management relationship types")
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

    {:noreply, stream_delete(socket, :knowledge_management_relationship_types, relationship_type)}
  end
end
