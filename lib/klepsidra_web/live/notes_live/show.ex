defmodule KlepsidraWeb.NotesLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.Categorisation
  alias LiveSelect.Component
  alias Klepsidra.DynamicCSS
  alias Klepsidra.KnowledgeManagement
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
