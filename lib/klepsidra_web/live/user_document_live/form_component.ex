defmodule KlepsidraWeb.UserDocumentLive.FormComponent do
  use KlepsidraWeb, :live_component

  alias Klepsidra.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_document records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user_document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="text" label="Id" />
        <.input field={@form[:document_type_id]} type="text" label="Document type" />
        <.input field={@form[:user_id]} type="text" label="User" />
        <.input field={@form[:unique_reference]} type="text" label="Unique reference" />
        <.input field={@form[:issued_by]} type="text" label="Issued by" />
        <.input field={@form[:issuing_country_id]} type="text" label="Issuing country" />
        <.input field={@form[:issue_date]} type="date" label="Issue date" />
        <.input field={@form[:expiry_date]} type="date" label="Expiry date" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <.input field={@form[:file_url]} type="text" label="File url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_document: user_document} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Documents.change_user_document(user_document))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user_document" => user_document_params}, socket) do
    changeset = Documents.change_user_document(socket.assigns.user_document, user_document_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user_document" => user_document_params}, socket) do
    save_user_document(socket, socket.assigns.action, user_document_params)
  end

  defp save_user_document(socket, :edit, user_document_params) do
    case Documents.update_user_document(socket.assigns.user_document, user_document_params) do
      {:ok, user_document} ->
        notify_parent({:saved, user_document})

        {:noreply,
         socket
         |> put_flash(:info, "User document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user_document(socket, :new, user_document_params) do
    case Documents.create_user_document(user_document_params) do
      {:ok, user_document} ->
        notify_parent({:saved, user_document})

        {:noreply,
         socket
         |> put_flash(:info, "User document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
