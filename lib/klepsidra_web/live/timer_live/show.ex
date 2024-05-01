defmodule KlepsidraWeb.TimerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.TimeTracking
  # alias Klepsidra.TimeTracking.Note
  alias KlepsidraWeb.Live.NoteLive.NoteFormComponent

  @impl true
  def mount(params, _session, socket) do
    timer_id = Map.get(params, "id")

    notes = TimeTracking.get_note_by_timer_id!(String.to_integer(timer_id))
    note_count = if length(notes) > 0, do: length(notes)
    note_pluralisation = if note_count == 1, do: "Note", else: "Notes"
    notes_title = [note_count, note_pluralisation] |> Enum.join(" ")

    socket =
      socket
      |> stream(:notes, notes)
      |> assign(:note_count, note_count)
      |> assign(:notes_title, notes_title)
      |> assign(:timer_id, timer_id)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:timer, TimeTracking.get_timer!(id))}
  end

  defp page_title(:show), do: "Show Timer"
  defp page_title(:edit), do: "Edit Timer"

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    note = TimeTracking.get_note!(id)

    {:ok, _} = TimeTracking.delete_note(note)

    note_count = socket.assigns.note_count - 1
    note_pluralisation = if note_count == 1, do: "Note", else: "Notes"
    notes_title = [note_count, note_pluralisation] |> Enum.join(" ")

    {:noreply,
     socket
     |> assign(:note_count, note_count)
     |> assign(:notes_title, notes_title)
     |> stream_delete(:notes, note)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved, _timer}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, note}}, socket) do
    note_count = socket.assigns.note_count + 1
    note_pluralisation = if note_count == 1, do: "Note", else: "Notes"
    notes_title = [note_count, note_pluralisation] |> Enum.join(" ")

    {:noreply,
     socket
     |> assign(:note_count, note_count)
     |> assign(:notes_title, notes_title)
     |> stream_insert(:notes, note, at: 0)}
  end
end
