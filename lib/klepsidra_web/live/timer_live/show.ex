defmodule KlepsidraWeb.TimerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast

  alias Klepsidra.TimeTracking
  alias KlepsidraWeb.Live.NoteLive.NoteFormComponent
  # alias KlepsidraWeb.Live.TagLive.SearchFormComponent

  @impl true
  def mount(params, _session, socket) do
    timer_id = Map.get(params, "id")
    return_to = Map.get(params, "return_to", "/timers")

    notes = TimeTracking.get_note_by_timer_id!(timer_id)

    note_metadata = title_notes_section(length(notes))

    socket =
      socket
      |> stream(:notes, notes)
      |> assign(:note_count, note_metadata.note_count)
      |> assign(:notes_title, note_metadata.section_title)
      |> assign(:timer_id, timer_id)
      |> assign(:return_to, return_to)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => _id, "note_id" => note_id}, _, socket) do
    socket = assign(socket, :note, TimeTracking.get_note!(note_id))

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:note, TimeTracking.get_note!(note_id))}
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:timer, TimeTracking.get_timer!(id))
     |> assign(:note, %Klepsidra.TimeTracking.Note{})}
  end

  defp page_title(:show), do: "Show Timer"
  defp page_title(:edit_timer), do: "Edit Timer"
  defp page_title(:new_note), do: "New note"
  defp page_title(:edit_note), do: "Edit note"

  @impl true
  def handle_event("delete_note", %{"id" => id}, socket) do
    {:noreply, handle_deleted_note(socket, TimeTracking.get_note!(id))}
  end

  # @impl true
  # def handle_event("keyboard_event", %{"key" => "n"} = _params, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(
  #      live_action: :new_note,
  #      page_title: "New note"
  #    )
  #    |> push_patch(to: ~p"/timers/#{socket.assigns.timer_id}/new-note")}
  # end

  # def handle_event("keyboard_event", _params, socket) do
  #   {:noreply, socket}
  # end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved, _timer}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:updated_open_timer, _timer}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:updated_closed_timer, _timer}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:updated_note, note}}, socket) do
    {:noreply, handle_updated_note(socket, note)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, note}}, socket) do
    {:noreply, handle_saved_note(socket, note)}
  end

  defp handle_saved_note(socket, note) do
    note_metadata = title_notes_section(socket.assigns.note_count + 1)

    socket
    |> assign(:note_count, note_metadata.note_count)
    |> assign(:notes_title, note_metadata.section_title)
    |> stream_insert(:notes, note, at: 0)
    |> put_toast(:info, "Note created successfully")
  end

  defp handle_updated_note(socket, note) do
    note_metadata = title_notes_section(socket.assigns.note_count + 1)

    socket
    |> assign(:note_count, note_metadata.note_count)
    |> assign(:notes_title, note_metadata.section_title)
    |> stream_insert(:notes, note)
    |> put_toast(:info, "Note updated successfully")
  end

  defp handle_deleted_note(socket, note) do
    {:ok, _} = TimeTracking.delete_note(note)

    note_metadata = title_notes_section(socket.assigns.note_count - 1)

    socket
    |> assign(:note_count, note_metadata.note_count)
    |> assign(:notes_title, note_metadata.section_title)
    |> stream_delete(:notes, note)
    |> put_toast(:info, "Note deleted successfully")
  end

  defp title_notes_section(note_count) when is_integer(note_count) do
    title_note_count = if note_count > 0, do: note_count, else: ""
    note_pluralisation = if note_count == 1, do: "Note", else: "Notes"

    %{
      note_count: note_count,
      title_pluralisation: note_pluralisation,
      section_title: [title_note_count, note_pluralisation] |> Enum.join(" ")
    }
  end
end
