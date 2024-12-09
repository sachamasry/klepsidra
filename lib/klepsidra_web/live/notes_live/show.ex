defmodule KlepsidraWeb.NotesLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.Categorisation
  alias LiveSelect.Component
  alias Klepsidra.DynamicCSS
  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.NoteRelation
  alias KlepsidraWeb.NotesLive.NoteRelationshipComponent
  alias Klepsidra.Repo
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities

  defmodule TagSearch do
    @moduledoc """
    The `TagSearch` module defines an embedded `tag_search` schema
    containing the tags for this note.
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
    note_id = Map.get(params, "id")

    note = KnowledgeManagement.get_note!(note_id) |> Repo.preload(:tags)

    formatted_status = note.status |> Atom.to_string() |> String.capitalize()

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(note.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(note.tags)
      )
      |> assign(
        live_select_form: to_form(TagSearch.changeset(%{}), as: "tag_form"),
        new_tag_colour: {"#94a3b8", "#fff"},
        formatted_status: formatted_status,
        note_id: note_id,
        outbound_notes: [%{id: "1", title: "Non-identification", summary: "", content: "See also Not-self. It is possible to notice an impulse, thought, desire, aversion, concern, etc, without identifying with that sensation. That is: the relationship can become “I sense a feeling of impatience” (akin to hearing a sound from the street outside), rather than “I’m impatient” or even “I can’t believe this is taking so long” (Everything takes longer than you think it will). This practice is not about ignoring impulses—you still sense them and can choose to act on them—but rather about making them an object rather than a subject, removing them from the driver’s seat, etc."}, %{id: "2", title: "Unsatisfactoriness", summary: "The nature of existence is that all phenomena are {impermanent}, {unsatisfactory}, and {not-self}.", content: "One of the Three characteristics of existence central to Buddhism. It describes the pervasive subtle suffering of life: one is always trying to escape thoughts, feelings, and concepts which are undesirable; or else one is grasping at objects of desire."}, %{id: "3", title: "Hedonic treadmill", summary: "Desire is the root of all unhappiness", content: "You find yourself wanting something so much—a new computer, a partner, a house, more intellectual freedom, more friends, etc—and then once you have them, the goalposts immediately shift. Those things you wanted so badly become normal, no longer something worthy of special aspiration, and now you simply find yourself wanting the next thing."}],
        inbound_notes: []
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    note = KnowledgeManagement.get_note!(id) |> Repo.preload(:tags)

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(note.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(note.tags)
      )
      |> assign(
        live_select_form: to_form(TagSearch.changeset(%{}), as: "tag_form"),
        new_tag_colour: {"#94a3b8", "#fff"}
      )
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:note, note)
      |> assign(note_relation: %NoteRelation{})

    {:noreply, socket}
  end

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
      socket.assigns.note.id,
      &KnowledgeManagement.add_knowledge_management_note_tag(&1, &2),
      &KnowledgeManagement.delete_knowledge_management_note_tag(&1, &2)
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
      socket.assigns.note.id,
      &KnowledgeManagement.add_knowledge_management_note_tag(&1, &2),
      &KnowledgeManagement.delete_knowledge_management_note_tag(&1, &2)
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

  @impl true
  def handle_info(
        {KlepsidraWeb.NotesLive.NoteRelationshipComponent, {:saved_note_relation, note_relation}},
        socket
      ) do
    {:noreply, handle_saved_note_relation(socket, note_relation)}
  end

  defp handle_saved_note_relation(socket, _note_relation) do
    # note_metadata = title_notes_section(socket.assigns.note_count + 1)

    socket
    # |> assign(:note_count, note_metadata.note_count)
    # |> assign(:notes_title, note_metadata.section_title)
    # |> stream_insert(:notes, note, at: 0)
    |> put_toast(:info, "Notes related successfully")
  end

  defp page_title(:show), do: "Show note"
  defp page_title(:edit), do: "Edit note"

  defp enable_tag_selector() do
    JS.remove_class("hidden", to: "#tag_form_tag_search_text_input")
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select--show")
    |> JS.add_class("hidden", to: "#tag-selector__add-button--show")
    |> JS.add_class("gap-2", to: "#tag-selector--show")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select--show")
    |> JS.focus(to: "#tag_form_tag_search_text_input")
  end
end
