defmodule KlepsidraWeb.NotesLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import KlepsidraWeb.RelatedEntityComponents
  import LiveToast

  alias Klepsidra.Categorisation
  alias Klepsidra.DynamicCSS
  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.NoteRelation
  alias KlepsidraWeb.NotesLive.NoteRelationshipComponent
  alias Klepsidra.Repo
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities
  alias LiveSelect.Component

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

    relationship_type_options =
      KnowledgeManagement.list_knowledge_management_relationship_type_options_for_select()

    default_relationship_type =
      KnowledgeManagement.get_default_knowledge_management_relationship_type_option_for_select()

    outbound_note_relations = KnowledgeManagement.list_related_notes(note_id, :outbound)
    inbound_note_relations = KnowledgeManagement.list_related_notes(note_id, :inbound)

    note_relation_counts =
      %{
        outbound: KnowledgeManagement.aggregate_related_notes(note_id, :outbound).count,
        inbound: KnowledgeManagement.aggregate_related_notes(note_id, :inbound).count
      }

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
        relationship_type_options: %{
          default: default_relationship_type,
          all: relationship_type_options
        },
        note_relation_counts: note_relation_counts
      )
      |> stream(:outbound_note_relations, outbound_note_relations)
      |> stream(:inbound_note_relations, inbound_note_relations)

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
        {KlepsidraWeb.NotesLive.NoteRelationshipComponent,
         {:saved_outbound_note_relation, note_relation}},
        socket
      ) do
    {:noreply, handle_saved_note_relation(socket, note_relation, :outbound)}
  end

  @impl true
  def handle_info(
        {KlepsidraWeb.NotesLive.NoteRelationshipComponent,
         {:saved_inbound_note_relation, note_relation}},
        socket
      ) do
    {:noreply, handle_saved_note_relation(socket, note_relation, :inbound)}
  end

  defp handle_saved_note_relation(socket, note_relation, :outbound) do
    # note_metadata = title_notes_section(socket.assigns.note_count + 1)

    socket
    |> stream_insert(:outbound_note_relations, note_relation, at: 0)
    # |> assign(:note_count, note_metadata.note_count)
    # |> assign(:notes_title, note_metadata.section_title)
    |> put_toast(:info, "Notes related successfully")
  end

  defp handle_saved_note_relation(socket, note_relation, :inbound) do
    # note_metadata = title_notes_section(socket.assigns.note_count + 1)

    socket
    |> stream_insert(:inbound_note_relations, note_relation, at: 0)
    # |> assign(:note_count, note_metadata.note_count)
    # |> assign(:notes_title, note_metadata.section_title)
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
