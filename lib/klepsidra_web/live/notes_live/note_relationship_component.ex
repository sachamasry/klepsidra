defmodule KlepsidraWeb.NotesLive.NoteRelationshipComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.NoteRelation

  @impl true
  def render(assigns) do
    ~H"""
    <div id="note-relationship-container">
      <section class="rounded-2xl my-6 p-6 bg-peach-fuzz-lightness-105">
        <h3 class="font-extrabold text-violet-900/50">
          Relate to other notes
        </h3>

        <.simple_form
          :let={f}
          for={@note_relation_form}
          id={@id}
          phx-submit="save"
          phx-change="validate"
          phx-target={@myself}
          phx-value-id={@note_id}
        >
          <.live_select
            field={f[:target_note_id]}
            mode={:single}
            label="Target note"
            allow_clear
            options={[]}
            placeholder="Select the note to relate to the open one"
            debounce={200}
            dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
            update_min_len={3}
            phx-target={@myself}
          >
            <:option :let={option}>
              <div class="group border-b hover:border-transparent border-peach-fuzz-300/50 py-2">
                <div class="flex">
                  <%= option.label %>
                </div>
                <div class="text-xs">
                  <%= option.result |> Phoenix.HTML.raw() %>
                </div>
              </div>
            </:option>
          </.live_select>

          <.input
            label="Relationship type"
            field={f[:relationship_type_id]}
            type="select"
            value={false}
            selected={@relationship_type_options.default}
            options={@relationship_type_options.all}
          />
          <.input label="Make this an inbound relation?" field={f[:reverse_relation]} type="checkbox" />
          <.button phx-disable-with="Saving note...">Relate</.button>
        </.simple_form>
      </section>

      <.relation_listing
        title="Links from this note"
        relation_direction={:outbound}
        related_notes={@outbound_note_relations}
        related_note_count={@note_relation_counts.outbound}
      />

      <.relation_listing
        title="Links to this note"
        relation_direction={:inbound}
        related_notes={@inbound_note_relations}
        related_note_count={@note_relation_counts.inbound}
      />
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = KnowledgeManagement.change_note_relation(%NoteRelation{})

    socket =
      socket
      |> assign_form(changeset)
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "new_note_relationship_target_note_id",
          "id" => live_select_id,
          "text" => note_search_phrase
        },
        socket
      ) do
    notes = search_notes(note_search_phrase, [])

    send_update(LiveSelect.Component, id: live_select_id, options: notes)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"note_relation" => note_relation_params}, socket) do
    changeset =
      %NoteRelation{}
      |> KnowledgeManagement.change_note_relation(note_relation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "id" => source_note_id,
          "relationship_type_id" => relationship_type_id,
          "target_note_id" => target_note_id
        },
        socket
      ) do
    note_relation_params = %{
      source_note_id: source_note_id,
      relationship_type_id: relationship_type_id,
      target_note_id: target_note_id
    }

    changeset =
      %NoteRelation{}
      |> KnowledgeManagement.change_note_relation(note_relation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{
          "id" => source_note_id,
          "relationship_type_id" => relationship_type_id,
          "target_note_id" => target_note_id,
          "reverse_relation" => reverse_relation
        },
        socket
      ) do
    note_relation_params =
      if reverse_relation == true do
        %{
          source_note_id: source_note_id,
          relationship_type_id: relationship_type_id,
          target_note_id: target_note_id
        }
      else
        %{
          source_note_id: target_note_id,
          relationship_type_id: relationship_type_id,
          target_note_id: source_note_id
        }
      end

    save_note_relation(socket, socket.assigns.action, note_relation_params)
  end

  defp save_note_relation(socket, :new_note_relation, note_relation_params) do
    case KnowledgeManagement.create_note_relation(note_relation_params) do
      {:ok, note_relation} ->
        notify_parent({:saved_note_relation, note_relation})

        changeset =
          KnowledgeManagement.change_note_relation(%NoteRelation{})

        {
          :noreply,
          socket
          |> assign_form(changeset)
          |> push_patch(to: socket.assigns.patch)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :note_relation_form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  attr(:title, :string, default: "Relate notes")
  attr(:id, :string, required: true, doc: "The ID of the relation-definer form")
  attr(:for, :any, required: true, doc: "The datastructure for the form")

  attr(:relationship_type_options, :list,
    default: [],
    doc: "A list of all possible relationship types, formatted for a select type input"
  )

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "Arbitrary HTML and Phoenix attributes to apply to the form"
  )

  def relationship_maker(assigns) do
    ~H"""
    <section class="rounded-2xl my-6 p-6 bg-peach-fuzz-lightness-105">
      <h3 class="font-extrabold text-violet-900/50">
        <%= @title %>
      </h3>
      <.simple_form :let={f} for={@for} id={@id}>
        <.input field={f[:target_note_id]} type="text" autocomplete="off" />

        <.live_select
          field={f[:target_note_id]}
          mode={:single}
          label="Target note"
          allow_clear
          options={[]}
          placeholder="Select the note to relate to the open one"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={3}
          phx-target="#_target_note_id_live_select_component"
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.input
          field={f[:relationship_type_id]}
          type="select"
          selected={@relationship_type_options.default}
          options={@relationship_type_options.all}
        />
        <.button phx-disable-with="Saving note...">Relate</.button>
      </.simple_form>
    </section>
    """
  end

  attr(:title, :string, default: "Links")

  attr(:relation_direction, :atom,
    values: [:outbound, :inbound],
    default: :outbound,
    doc:
      "Defines whether the relationship stems out from this note to the related one `:outbound`, or in from the related note `:inbound`"
  )

  attr(:related_notes, :list,
    required: true,
    doc: "List of related notes to pass to Phoenix.HTML.Form.options_for_select/2"
  )

  attr(:related_note_count, :integer, default: 0, doc: "Count of all related notes")

  def relation_listing(assigns) do
    ~H"""
    <section
      :if={@related_notes != []}
      class="rounded-2xl my-6 p-6 bg-peach-fuzz-lightness-105 grid grid-cols-2 gap-6"
    >
      <h3 class="font-extrabold text-violet-900/50 col-span-2">
        <%= @title %> (<%= @related_note_count %>)
      </h3>
      <.related_notes
        :for={note <- @related_notes}
        relation_direction={@relation_direction}
        note={note}
      />
    </section>
    """
  end

  attr(:relation_direction, :atom,
    values: [:outbound, :inbound],
    default: :outbound,
    doc:
      "Defines whether the relationship stems out from this note to the related one `:outbound`, or in from the related note `:inbound`"
  )

  attr :note, :map, required: true

  def related_notes(assigns) do
    ~H"""
    <article class="group col-span-1 rounded-lg max-h-48 overflow-clip p-6 bg-peach-fuzz-lightness-75 hover:bg-peach-fuzz-600 hover:text-white hover:cursor-pointer">
      <.link navigate={~p"/knowledge_management/notes/#{@note.id}"}>
        <header>
          <h5 class="uppercase text-xs text-peach-fuzz-500 group-hover:text-white">
            <.icon :if={@relation_direction == :inbound} name="hero-arrow-long-left" class="h-4 w-4" />
            <%= if(@relation_direction == :inbound,
              do: @note.reverse_relationship_type,
              else: @note.relationship_type
            ) %>
            <.icon
              :if={@relation_direction == :outbound}
              name="hero-arrow-long-right"
              class="h-4 w-4"
            />
          </h5>
          <h4 class="font-semibold mb-4">
            <%= @note.title %>
          </h4>
          <div :if={@note.summary} class="line-clamp-2 mb-4 italic">
            <%= @note.summary %>
          </div>
        </header>
        <div class={if(@note.summary, do: "line-clamp-2", else: "line-clamp-4")}>
          <%= @note.content |> Phoenix.HTML.raw() %>
        </div>
      </.link>
    </article>
    """
  end

  defp search_notes(search_phrase, default) when is_bitstring(search_phrase) do
    try do
      KnowledgeManagement.search_notes_and_highlight_snippet_options_for_select(search_phrase)
    rescue
      Exqlite.Error ->
        default
    end
  end
end
