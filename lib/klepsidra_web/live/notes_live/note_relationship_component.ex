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

    socket =
      socket
      |> assign_form(changeset)

    {:noreply, socket}
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

    socket =
      socket
      |> assign_form(changeset)

    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{
          "id" => current_note_id,
          "relationship_type_id" => relationship_type_id,
          "target_note_id" => target_note_id,
          "reverse_relation" => "false"
        },
        socket
      ) do
    note_relation_params =
      construct_note_relation_map(current_note_id, target_note_id, relationship_type_id)

    save_note_relation(socket, socket.assigns.action, note_relation_params, :outbound)
  end

  def handle_event(
        "save",
        %{
          "id" => current_note_id,
          "relationship_type_id" => relationship_type_id,
          "target_note_id" => target_note_id,
          "reverse_relation" => "true"
        },
        socket
      ) do
    note_relation_params =
      construct_note_relation_map(target_note_id, current_note_id, relationship_type_id)

    save_note_relation(socket, socket.assigns.action, note_relation_params, :inbound)
  end

  defp save_note_relation(socket, :new_note_relation, note_relation_params, direction) do
    case KnowledgeManagement.create_note_relation(note_relation_params) do
      {:ok, note_relation} ->
        note_relation =
          KnowledgeManagement.get_related_note(
            note_relation.source_note_id,
            note_relation.target_note_id,
            note_relation.relationship_type_id,
            direction
          )

        if direction == :inbound do
          notify_parent({:saved_inbound_note_relation, note_relation})
        else
          notify_parent({:saved_outbound_note_relation, note_relation})
        end

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

  defp construct_note_relation_map(source_note_id, target_note_id, relationship_type_id) do
    %{
      source_note_id: source_note_id,
      target_note_id: target_note_id,
      relationship_type_id: relationship_type_id
    }
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

  defp search_notes(search_phrase, default) when is_bitstring(search_phrase) do
    try do
      KnowledgeManagement.search_notes_and_highlight_snippet_options_for_select(search_phrase)
    rescue
      Exqlite.Error ->
        default
    end
  end
end
