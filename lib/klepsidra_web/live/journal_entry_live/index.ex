defmodule KlepsidraWeb.JournalEntryLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntry
  import LiveToast

  @impl true
  def mount(_params, _session, socket) do
    datestamp = Date.utc_today() |> Date.to_string()

    journal_entries =
      Journals.list_journal_entries()
      |> Journals.preload_journal_entry_type()

    {:ok,
     socket
     |> assign(:datestamp, datestamp)
     |> stream(:journal_entries, journal_entries)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit journal entry")
    |> assign(:journal_entry, Journals.get_journal_entry!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New journal entry")
    |> assign(:journal_entry, %JournalEntry{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Journal entries")
    |> assign(:journal_entry, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.JournalEntryLive.FormComponent, {:saved, journal_entry}}, socket) do
    {:noreply, stream_insert(socket, :journal_entries, journal_entry)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    journal_entry = Journals.get_journal_entry!(id)
    {:ok, _} = Journals.delete_journal_entry(journal_entry)

    socket =
      socket
      |> stream_delete(:journal_entries, journal_entry)
      |> put_toast(:info, "Journal entry deleted succesfully")

    {:noreply, socket}
  end
end