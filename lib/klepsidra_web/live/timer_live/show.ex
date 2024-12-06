defmodule KlepsidraWeb.TimerLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import LiveToast

  import KlepsidraWeb.ButtonComponents
  alias Klepsidra.Categorisation
  alias LiveSelect.Component
  alias Klepsidra.DynamicCSS
  alias KlepsidraWeb.Live.NoteLive.NoteFormComponent
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities
  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.TimeTracking.TimeUnits, as: Units

  defmodule TagSearch do
    @moduledoc """
    The `TagSearch` module defines an embedded `tag_search` schema
    containing the tags for this timer.
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

    timer_description =
      case timer.description do
        nil ->
          ""

        _ ->
          Earmark.as_html!(timer.description,
            breaks: true,
            code_class_prefix: "lang- language-",
            compact_output: false,
            escape: false,
            footnotes: true,
            gfm_tables: true,
            smartypants: true,
            sub_sup: true
          )
          |> HtmlSanitizeEx.html5()
          |> Phoenix.HTML.raw()
      end

    return_to = Map.get(params, "return_to", "/timers")

    notes = TimeTracking.get_note_by_timer_id!(timer_id)

    note_metadata = title_notes_section(length(notes))

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(timer.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(timer.tags)
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
        timer_description: timer_description,
        return_to: return_to
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:timer, TimeTracking.get_timer!(id))
    |> assign(:note, %Klepsidra.TimeTracking.Note{})
  end

  defp apply_action(socket, :edit_timer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Timer")
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :stop_timer, %{"id" => id}) do
    start_timestamp = TimeTracking.get_timer!(id).start_stamp
    clocked_out = Timer.clock_out(start_timestamp, :minute)
    billing_duration_unit = Units.get_default_billing_increment()

    billing_duration =
      Timer.calculate_timer_duration(
        start_timestamp,
        clocked_out.end_timestamp,
        String.to_existing_atom(billing_duration_unit)
      )

    socket
    |> assign(:page_title, "Clock out")
    |> assign(
      clocked_out: clocked_out,
      duration_unit: "minute",
      billing_duration: billing_duration,
      billing_duration_unit: billing_duration_unit
    )
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :new_note, %{"id" => id} = _params) do
    socket
    |> assign(:page_title, "New note")
    |> assign(:timer_id, id)
  end

  defp apply_action(socket, nil, _params), do: socket

  defp apply_action(socket, :edit_note, %{"id" => _id, "note_id" => note_id}) do
    socket
    |> assign(
      note: TimeTracking.get_note!(note_id),
      page_title: page_title(socket.assigns.live_action)
    )
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
    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      [],
      socket.assigns.timer.id,
      &Categorisation.add_timer_tag(&1, &2),
      &Categorisation.delete_timer_tag(&1, &2)
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
      socket.assigns.timer.id,
      &Categorisation.add_timer_tag(&1, &2),
      &Categorisation.delete_timer_tag(&1, &2)
    )

    socket =
      TagUtilities.generate_tag_options(
        socket,
        socket.assigns.selected_tag_queue,
        selected_tags,
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(selected_tags)
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
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved_closed_timer, timer}}, socket) do
    {:noreply, handle_closed_timer(socket, timer)}
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
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:timer_stopped, timer}}, socket) do
    {:noreply, handle_closed_timer(socket, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:updated_note, note}}, socket) do
    {:noreply, handle_updated_note(socket, note)}
  end

  @impl true
  def handle_info({KlepsidraWeb.Live.NoteLive.NoteFormComponent, {:saved_note, note}}, socket) do
    {:noreply, handle_saved_note(socket, note)}
  end

  defp handle_closed_timer(socket, _timer) do
    # closed_timer_duration = {timer.duration, timer.duration_time_unit}

    socket
    |> put_toast(:info, "Timer stopped")
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
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select--show")
    |> JS.add_class("hidden", to: "#tag-selector__add-button--show")
    |> JS.add_class("gap-2", to: "#tag-selector--show")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select--show")
    |> JS.focus(to: "#tag_form_tag_search_text_input")
  end
end
