defmodule KlepsidraWeb.ProjectLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.Categorisation
  alias LiveSelect.Component
  alias Klepsidra.DynamicCSS
  alias Klepsidra.Projects
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities
  alias Klepsidra.TimeTracking.Timer
  alias Klepsidra.Cldr.Unit

  defmodule TagSearch do
    @moduledoc """
    The `TagSearch` module defines an embedded `tag_search` schema
    containing the tags for this project.
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
    project_id = Map.get(params, "id")

    project = Klepsidra.Projects.get_project!(project_id) |> Klepsidra.Repo.preload(:tags)

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(project.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(project.tags)
      )
      |> assign(
        live_select_form: to_form(TagSearch.changeset(%{}), as: "tag_form"),
        new_tag_colour: {"#94a3b8", "#fff"}
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    aggregate_project_duration =
      get_aggregate_duration_for_project(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:project, Projects.get_project!(id))
      |> assign(
        aggregate_project_duration: aggregate_project_duration.base_unit_duration,
        duration_in_hours: aggregate_project_duration.duration_in_hours,
        human_readable_duration: aggregate_project_duration.human_readable_duration
      )

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
      socket.assigns.project.id,
      &Categorisation.add_project_tag(&1, &2),
      &Categorisation.delete_project_tag(&1, &2)
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
      socket.assigns.project.id,
      &Categorisation.add_project_tag(&1, &2),
      &Categorisation.delete_project_tag(&1, &2)
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

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"

  @impl true
  def handle_info({KlepsidraWeb.ProjectLive.FormComponent, {:saved, _project}}, socket) do
    {:noreply, socket}
  end

  defp get_aggregate_duration_for_project(project_id) do
    project_id
    |> Klepsidra.TimeTracking.get_closed_timer_durations_for_project()
    |> Timer.convert_durations_to_base_time_unit()
    |> Timer.sum_base_unit_durations()
    |> format_aggregate_duration_for_project()
  end

  defp format_aggregate_duration_for_project(base_unit_duration) do
    %{
      base_unit_duration: base_unit_duration,
      duration_in_hours:
        base_unit_duration
        |> Unit.convert!(:hour)
        |> then(fn i -> Cldr.Unit.round(i, 1) end)
        |> Unit.to_string!(),
      human_readable_duration:
        Timer.format_human_readable_duration(base_unit_duration,
          unit_list: [
            :day,
            :hour_increment
          ],
          return_if_short_duration: false
        )
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
