defmodule KlepsidraWeb.NotesLive.NoteRelationshipComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="note-relationship-container">
      <h3>Related notes</h3>
    </div>
    """
  end

  @impl true
  # def update(%{note_relationship: note_relationship} = assigns, socket) do
  def update(assigns, socket) do
    # changeset = TimeTracking.change_note(note_relationship)

    socket =
      socket
      # |> assign_form(%Ecto.Changeset{})
      |> assign(assigns)

    {:ok, socket}
  end

  # @impl true
  # def handle_event("validate", %{"note" => note_params}, socket) do
  # end

  # defp save_note(socket, :new_note, note_params) do
  # case TimeTracking.create_note(note_params) do
  #   {:ok, note} ->
  #     notify_parent({:saved_note, note})

  #     changeset =
  #       TimeTracking.change_note(%Note{})

  #     {
  #       :noreply,
  #       socket
  #       |> assign_form(changeset)
  #       |> push_patch(to: socket.assigns.patch)
  #     }

  #   {:error, %Ecto.Changeset{} = changeset} ->
  #     {:noreply, assign_form(socket, changeset)}
  # end
  # end

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

  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   assign(socket, :note_relationship_form, to_form(changeset))
  # end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
