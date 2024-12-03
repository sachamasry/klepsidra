defmodule KlepsidraWeb.NotesLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.KnowledgeManagement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="notes-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />

        <.input field={@form[:content]} type="textarea" label="Note content" />
        <.input
          field={@form[:content_format]}
          type="select"
          label="Content format"
          prompt="Choose a value"
          selected="markdown"
          options={Ecto.Enum.values(Klepsidra.KnowledgeManagement.Note, :content_format)}
        />
        <.input field={@form[:summary]} type="text" label="Summary" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          selected="fleeting"
          options={Ecto.Enum.values(Klepsidra.KnowledgeManagement.Note, :status)}
        />
        <.input field={@form[:review_date]} type="date" label="Review date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save note</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{note: note} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(KnowledgeManagement.change_notes(note))
     end)}
  end

  @impl true
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset = KnowledgeManagement.change_notes(socket.assigns.note, note_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    save_notes(socket, socket.assigns.action, note_params)
  end

  defp save_notes(socket, :edit, note_params) do
    case KnowledgeManagement.update_notes(socket.assigns.note, note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_toast(:info, "Note updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_notes(socket, :new, note_params) do
    case KnowledgeManagement.create_notes(note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_toast(:info, "Note created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
