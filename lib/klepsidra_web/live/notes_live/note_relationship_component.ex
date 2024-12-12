defmodule KlepsidraWeb.NotesLive.NoteRelationshipComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.NoteRelation

  @impl true
  def render(assigns) do
    ~H"""
    <div id="note-relationship-container">
      <h3>Related notes</h3>
      <.simple_form
        for={@note_relation_form}
        id="note-relation-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        phx-value-id={@note_id}
      >
        <.input field={@note_relation_form[:target_note_id]} type="text" autocomplete="off" />
        <.input field={@note_relation_form[:relationship_type_id]} type="text" autocomplete="off" />
        <.button phx-disable-with="Saving note...">Relate notes</.button>
      </.simple_form>
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
end
