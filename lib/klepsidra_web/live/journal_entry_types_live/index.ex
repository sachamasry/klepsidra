defmodule KlepsidraWeb.JournalEntryTypesLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast
  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntryTypes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :journal_entry_types_collection, Journals.list_journal_entry_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit journal entry type")
    |> assign(:journal_entry_types, Journals.get_journal_entry_types!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New journal entry type")
    |> assign(:journal_entry_types, %JournalEntryTypes{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Journal entry types")
    |> assign(:journal_entry_types, nil)
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.JournalEntryTypesLive.FormComponent, {:saved, journal_entry_types}},
        socket
      ) do
    {:noreply, stream_insert(socket, :journal_entry_types_collection, journal_entry_types)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    journal_entry_types = Journals.get_journal_entry_types!(id)
    {:ok, _} = Journals.delete_journal_entry_types(journal_entry_types)

    {:noreply,
     handle_deleted_journal_entry_type(socket, journal_entry_types, :journal_entry_types)}
  end

  defp handle_deleted_journal_entry_type(socket, journal_entry_type, source_stream) do
    socket
    |> stream_delete(source_stream, journal_entry_type)
    |> put_toast(:info, "Journal entry type deleted successfully")
  end
end
