defmodule KlepsidraWeb.DocumentTypeLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.Documents

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
        id="document_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save document type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document_type: document_type} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Documents.change_document_type(document_type))
     end)}
  end

  @impl true
  def handle_event("validate", %{"document_type" => document_type_params}, socket) do
    changeset = Documents.change_document_type(socket.assigns.document_type, document_type_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"document_type" => document_type_params}, socket) do
    save_document_type(socket, socket.assigns.action, document_type_params)
  end

  defp save_document_type(socket, :edit, document_type_params) do
    case Documents.update_document_type(socket.assigns.document_type, document_type_params) do
      {:ok, document_type} ->
        notify_parent({:saved, document_type})

        {:noreply,
         socket
         |> put_toast(:info, "Document type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document_type(socket, :new, document_type_params) do
    case Documents.create_document_type(document_type_params) do
      {:ok, document_type} ->
        notify_parent({:saved, document_type})

        {:noreply,
         socket
         |> put_toast(:info, "Document type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
