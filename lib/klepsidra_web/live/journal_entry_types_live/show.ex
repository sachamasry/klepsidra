defmodule KlepsidraWeb.JournalEntryTypesLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Journals

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:journal_entry_types, Journals.get_journal_entry_types!(id))}
  end

  defp page_title(:show), do: "Show journal entry type"
  defp page_title(:edit), do: "Edit journal entry type"
end
