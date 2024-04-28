defmodule KlepsidraWeb.Live.NoteLive.NoteFormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Note

  @impl true
  def mount(socket) do
    changeset = TimeTracking.change_note(%Note{})

    {:ok, assign(socket, :note_form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@note_form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.input field={@note_form[:note]} type="text" placeholder="Notes" autocomplete="off" />
        <.button>Save note</.button>
      </.simple_form>
    </div>
    """
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
    save_note(socket, note_params)
  end

  @spec save_note(map(), map()) :: {:noreply, map()}
  defp save_note(socket, note_params) do
    case TimeTracking.create_note(note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})
        socket = assign(socket, :notes, note)

        {:noreply,
         socket
         |> put_flash(:info, "Note created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
