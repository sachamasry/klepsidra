defmodule KlepsidraWeb.Live.NoteLive.NoteFormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Note

  # @impl true
  # def mount(socket) do
  #   changeset =
  #     TimeTracking.change_note(%Note{})

  #   {:ok, assign(socket, :note_form, to_form(changeset))}
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@note_form}
        id="note-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        phx-value-id={@note_form.data.id}
      >
        <.input
          field={@note_form[:note]}
          type="textarea"
          placeholder="Type a new note here"
          autocomplete="off"
        />
        <.button phx-disable-with="Saving note...">Save note</.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{note: note} = assigns, socket) do
    changeset = TimeTracking.change_note(note)

    socket =
      socket
      |> assign_form(changeset)
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    changeset = TimeTracking.change_note(%Note{})

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(assigns)}
  end

  @impl true
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset =
      %Note{}
      |> TimeTracking.change_note(note_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    note_params = Map.put(note_params, "timer_id", socket.assigns.timer_id)

    save_note(socket, socket.assigns.action, note_params)
  end

  defp save_note(socket, :edit_note, note_params) do
    case TimeTracking.update_note(socket.assigns.note, note_params) do
      {:ok, note} ->
        notify_parent({:updated_note, note})

        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_note(socket, :new_note, note_params) do
    case TimeTracking.create_note(note_params) do
      {:ok, note} ->
        notify_parent({:saved_note, note})

        changeset =
          TimeTracking.change_note(%Note{})

        {
          :noreply,
          socket
          |> assign_form(changeset)
          |> put_flash(:info, "Note created successfully")
          #  |> push_patch(to: socket.assigns.patch)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :note_form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
