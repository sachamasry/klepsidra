defmodule KlepsidraWeb.TimerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import LiveToast

  alias Klepsidra.TimeTracking
  alias KlepsidraWeb.Live.NoteLive.NoteFormComponent
  alias KlepsidraWeb.TagLive.TagUtilities
  alias Klepsidra.DynamicCSS
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag
  alias LiveSelect.Component

  defmodule TagSearch do
    @moduledoc """
    The `TagSearch` module defines an embedded `tag_search` schema
    containing many tags for this timer.
    """
    use Ecto.Schema

    import Ecto.Changeset

    @type t :: %__MODULE__{
            tag_search: Tag.t()
          }
    embedded_schema do
      embeds_many(:tag_search, Tag, on_replace: :delete)
      field(:bg_colour, :string)
    end

    @doc false
    def changeset(schema \\ %__MODULE__{}, params) do
      cast(schema, params, [])
      |> cast_embed(:tag_search)
    end
  end

  @tag_search_live_component_id "tag_form_tag_search_live_select_component"

  @impl true
  def mount(params, _session, socket) do
    timer_id = Map.get(params, "id")
    timer = Klepsidra.TimeTracking.get_timer!(timer_id) |> Klepsidra.Repo.preload(:tags)
    return_to = Map.get(params, "return_to", "/timers")

    notes = TimeTracking.get_note_by_timer_id!(timer_id)

    note_metadata = title_notes_section(length(notes))

    socket =
      TagUtilities.generate_tag_options(
        socket,
        [],
        Enum.map(timer.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )

    socket =
      socket
      |> stream(:notes, notes)
      |> assign(
        live_select_form: to_form(TagSearch.changeset(%{}), as: "tag_form"),
        new_tag_colour: {"#94a3b8", "#fff"},
        note_count: note_metadata.note_count,
        notes_title: note_metadata.section_title,
        timer_id: timer_id,
        return_to: return_to,
        style_declarations: "p { color: orange; }"
      )

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
  def handle_event(
        "live_select_change",
        %{
          "field" => "tag_form_tag_search",
          "id" => @tag_search_live_component_id,
          "text" => tag_search_phrase
        },
        socket
      ) do
    tag_search_results =
      Categorisation.search_tags_by_name_content(tag_search_phrase)
      |> TagUtilities.tag_options_for_live_select()

    send_update(Component,
      id: @tag_search_live_component_id,
      options: tag_search_results
    )

    socket =
      socket
      |> assign(
        tag_search_phrase: tag_search_phrase,
        possible_free_tag_entered: true
      )

    {:noreply, socket}
  end

  def handle_event(
        "change",
        %{
          "_target" => ["tag_form", "tag_search_empty_selection"],
          "tag_form" => %{
            "tag_search_empty_selection" => "",
            "tag_search_text_input" => _tag_search_phrase
          }
        },
        socket
      ) do
    Tag.handle_tag_list_changes(socket.assigns.selected_tag_queue, [], socket.assigns.timer.id)

    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "change",
        %{
          "_target" => ["tag_form", "tag_search"],
          "tag_form" => %{
            "tag_search" => selected_tags,
            "tag_search_text_input" => _tag_search_phrase
          }
        },
        socket
      ) do
    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      selected_tags,
      socket.assigns.timer.id
    )

    socket =
      TagUtilities.generate_tag_options(
        socket,
        socket.assigns.selected_tag_queue,
        selected_tags,
        @tag_search_live_component_id
      )

    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "change",
        %{
          "_target" => ["tag_form", "bg_colour"],
          "tag_form" => %{
            "bg_colour" => bg_colour,
            "tag_search_text_input" => _tag_search_phrase
          }
        },
        socket
      ) do
    fg_colour =
      case ColorContrast.calc_contrast(bg_colour) do
        {:ok, fg_colour} -> fg_colour
        {:error, _} -> "#fff"
      end

    socket =
      socket
      |> assign(new_tag_colour: {bg_colour, fg_colour})

    {:noreply, socket}
  end

  def handle_event(
        "ls_tag_search_blur",
        %{"id" => @tag_search_live_component_id},
        socket
      ) do
    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "key_up",
        %{"key" => "Enter"},
        %{assigns: %{tag_search_phrase: tag_search_phrase, possible_free_tag_entered: true}} =
          socket
      ) do
    socket =
      TagUtilities.handle_free_tagging(
        socket,
        tag_search_phrase,
        String.length(tag_search_phrase),
        @tag_search_live_component_id,
        socket.assigns.new_tag_colour
      )

    {:noreply, socket}
  end

  def handle_event("key_up", %{"key" => _}, socket), do: {:noreply, socket}

  def handle_event("delete_note", %{"id" => id}, socket) do
    {:noreply, handle_deleted_note(socket, TimeTracking.get_note!(id))}
  end

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

  defp enable_tag_selector() do
    JS.remove_class("hidden", to: "#tag_form_tag_search_text_input")
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select")
    |> JS.add_class("hidden", to: "#tag-selector__add-button")
    |> JS.add_class("gap-2", to: "#tag-selector")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select")
    |> JS.focus(to: "#tag_form_tag_search_text_input")
  end
end
