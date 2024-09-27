defmodule KlepsidraWeb.JournalEntryLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Journals

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    journal_entry = Journals.get_journal_entry!(id)

    journal_entry_type =
      journal_entry.entry_type_id
      |> Journals.get_journal_entry_types!()
      |> Map.get(:name)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:journal_entry, journal_entry)
     |> assign(:journal_entry_type, journal_entry_type)}
  end

  defp page_title(:show), do: "Show journal entry"
  defp page_title(:edit), do: "Edit journal entry"
end
