defmodule KlepsidraWeb.JournalEntryLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntry
  alias Klepsidra.Locations.City

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    journal_entry = get_journal(id)

    journal_entry_type = get_journal_entry_type(journal_entry.entry_type_id |> to_string())
    location_select_value = City.city_option_for_select(journal_entry.location_id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:journal_entry, journal_entry)
     |> assign(:journal_entry_type, journal_entry_type)
     |> assign(:location_formatted_name, location_select_value.label)}
  end

  defp page_title(:show), do: "Show journal entry"
  defp page_title(:edit), do: "Edit journal entry"

  @spec get_journal(id :: Ecto.UUID.t()) :: JournalEntry.t()
  defp get_journal(id), do: Journals.get_journal_entry!(id)

  @spec get_journal_entry_type(journal_entry_type_id :: Ecto.UUID.t()) ::
          String.t()
  defp get_journal_entry_type(journal_entry_type_id) when is_bitstring(journal_entry_type_id) do
    journal_entry_type_id
    |> Journals.get_journal_entry_types!()
    |> Map.get(:name)
  end
end
