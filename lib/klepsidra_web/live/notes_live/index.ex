defmodule KlepsidraWeb.NotesLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.Note
  alias KlepsidraWeb.NotesLive.SearchComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(show_search: false)

    {:ok,
     stream(
       socket,
       :knowledge_management_notes,
       KnowledgeManagement.list_knowledge_management_notes()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit note")
    |> assign(:note, KnowledgeManagement.get_note!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New note")
    |> assign(:note, %Note{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Knowledge management notes")
    |> assign(:note, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.NotesLive.FormComponent, {:saved, note}}, socket) do
    {:noreply, stream_insert(socket, :knowledge_management_notes, note)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    note = KnowledgeManagement.get_note!(id)
    {:ok, _} = KnowledgeManagement.delete_note(note)

    {:noreply, handle_deleted_note(socket, note, :knowledge_management_notes)}
  end

  @impl true
  def handle_event("search_notes", %{"show_search" => show_search}, socket) do
    socket =
      socket
      |> assign(show_search: show_search)

    {:noreply, socket}
  end

  defp handle_deleted_note(socket, note, source_stream) do
    socket
    |> stream_delete(source_stream, note)
    |> put_toast(:info, "Note deleted successfully")
  end
end
