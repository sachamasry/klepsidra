defmodule KlepsidraWeb.AnnotationLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.KnowledgeManagement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage annotation records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="annotation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" />
        <.input field={@form[:text]} type="text" label="Text" />
        <.input field={@form[:entry_type]} type="text" label="Entry type" />
        <.input field={@form[:author_name]} type="text" label="Author name" />
        <.input field={@form[:comment]} type="text" label="Comment" />
        <.input field={@form[:position_reference]} type="text" label="Position reference" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Annotation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{annotation: annotation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(KnowledgeManagement.change_annotation(annotation))
     end)}
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
         |> put_flash(:info, "Annotation updated successfully")
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
         |> put_flash(:info, "Annotation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
