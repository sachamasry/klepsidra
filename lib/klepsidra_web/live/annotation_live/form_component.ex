defmodule KlepsidraWeb.AnnotationLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.KnowledgeManagement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Record source material annotations or quotes</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="annotation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:entry_type]}
          type="select"
          label="Entry type"
          options={@entry_type_options}
        />
        <.input field={@form[:text]} type="textarea" placeholder="Annotation or quote" label="Text" />
        <.input field={@form[:author_name]} type="text" label="Author" />
        <.input
          field={@form[:position_reference]}
          type="text"
          label="Position reference"
          placeholder="Accurately reference the source of the annotation or quote"
        />
        <.input
          field={@form[:comment]}
          type="textarea"
          label="Comment"
          placeholder="Personal comments on the annotation or quote"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save annotation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(entry_type_options: [Annotation: "annotation", Quote: "quote"])
      |> assign_new(:form, fn ->
        to_form(KnowledgeManagement.change_annotation(annotation))
      end)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"annotation" => annotation_params}, socket) do
    changeset =
      KnowledgeManagement.change_annotation(socket.assigns.annotation, annotation_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"annotation" => annotation_params}, socket) do
    save_annotation(socket, socket.assigns.action, annotation_params)
  end

  defp save_annotation(socket, :edit, annotation_params) do
    case KnowledgeManagement.update_annotation(socket.assigns.annotation, annotation_params) do
      {:ok, annotation} ->
        notify_parent({:saved, annotation})

        {:noreply,
         socket
         |> put_toast(:info, "Annotation updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_annotation(socket, :new, annotation_params) do
    case KnowledgeManagement.create_annotation(annotation_params) do
      {:ok, annotation} ->
        notify_parent({:saved, annotation})

        {:noreply,
         socket
         |> put_toast(:info, "Annotation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
