defmodule KlepsidraWeb.RelationshipTypeLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.KnowledgeManagement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage relationship_type records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="relationship_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:is_predefined]} type="checkbox" label="Is predefined" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Relationship type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{relationship_type: relationship_type} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(KnowledgeManagement.change_relationship_type(relationship_type))
     end)}
  end

  @impl true
  def handle_event("validate", %{"relationship_type" => relationship_type_params}, socket) do
    changeset =
      KnowledgeManagement.change_relationship_type(
        socket.assigns.relationship_type,
        relationship_type_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"relationship_type" => relationship_type_params}, socket) do
    save_relationship_type(socket, socket.assigns.action, relationship_type_params)
  end

  defp save_relationship_type(socket, :edit, relationship_type_params) do
    case KnowledgeManagement.update_relationship_type(
           socket.assigns.relationship_type,
           relationship_type_params
         ) do
      {:ok, relationship_type} ->
        notify_parent({:saved, relationship_type})

        {:noreply,
         socket
         |> put_flash(:info, "Relationship type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_relationship_type(socket, :new, relationship_type_params) do
    case KnowledgeManagement.create_relationship_type(relationship_type_params) do
      {:ok, relationship_type} ->
        notify_parent({:saved, relationship_type})

        {:noreply,
         socket
         |> put_flash(:info, "Relationship type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
