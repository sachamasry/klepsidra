defmodule KlepsidraWeb.NotesLive.NoteRelationshipComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.NoteRelation

  @impl true
  def render(assigns) do
    ~H"""
    <div id="note-relationship-container">
      <.relationship_maker
        title="Relate to other notes"
        id="note-relation-form"
        for={@note_relation_form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        phx-value-id={@note_id}
      />

      <.relation_listing related_notes={@outbound_notes} title="Links from this note" />

      <.relation_listing related_notes={@inbound_notes} title="Links to this note" />
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
  def handle_event("validate", %{"note_relation" => note_relation_params}, socket) do
    changeset =
      %NoteRelation{}
      |> KnowledgeManagement.change_note_relation(note_relation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"id" => id, "note_relation" => note_relation_params},
        socket
      ) do
    note_relation_params = Map.put(note_relation_params, "source_note_id", id)

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

  # defp save_note(socket, :new_embedded_note, note_params) do
  # case TimeTracking.create_note(note_params) do
  #   {:ok, note} ->
  #     notify_parent({:saved_note, note})

  #     changeset =
  #       TimeTracking.change_note(%Note{})

  #     {
  #       :noreply,
  #       socket
  #       |> assign_form(changeset)
  #     }

  #   {:error, %Ecto.Changeset{} = changeset} ->
  #     {:noreply, assign_form(socket, changeset)}
  # end
  # end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :note_relation_form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  attr(:title, :string, default: "Relate notes")
  attr(:id, :string, required: true, doc: "The ID of the relation-definer form")
  attr(:for, :any, required: true, doc: "The datastructure for the form")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "Arbitrary HTML and Phoenix attributes to apply to the form"
  )

  def relationship_maker(assigns) do
    ~H"""
    <section class="rounded-lg my-6 p-6 bg-peach-fuzz-lightness-105">
      <h3 class="font-extrabold text-violet-900/50">
        <%= @title %>
      </h3>
      <.simple_form :let={f} for={@for} id={@id}>
        <.input field={f[:target_note_id]} type="text" autocomplete="off" />
        <.input field={f[:relationship_type_id]} type="text" autocomplete="off" />
        <.button phx-disable-with="Saving note...">Relate</.button>
      </.simple_form>
    </section>
    """
  end

  attr(:title, :string, default: "Links")

  attr(:related_notes, :list,
    required: true,
    doc: "List of related notes to pass to Phoenix.HTML.Form.options_for_select/2"
  )

  def relation_listing(assigns) do
    ~H"""
    <section :if={@related_notes != []} class="rounded-lg my-6 p-6 bg-peach-fuzz-lightness-105">
      <h3 class="font-extrabold text-violet-900/50">
        <%= @title %>
      </h3>
      <div :for={note <- @related_notes}>
        <.related_notes note={note} />
      </div>
    </section>
    """
  end

  attr :note, :map, required: true

  def related_notes(assigns) do
    ~H"""
    <article>
      <header>
        <h4>
          <%= @note.title %>
        </h4>
        <div>
          <%= @note.summary %>
        </div>
      </header>
      <div>
        <%= @note.content %>
      </div>
    </article>
    """
  end
end
