defmodule KlepsidraWeb.UserDocumentLive.FormComponent do
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
        id="user_document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:user_id]} type="text" label="User" />
        <.input field={@form[:document_type_id]} type="text" label="Document type" />
        <.input field={@form[:country_id]} type="text" label="Issuing country" />
        <.input field={@form[:document_issuer_id]} type="text" label="Document issuer" />
        <.input field={@form[:unique_reference_number]} type="text" label="Unique reference number" />
        <.input field={@form[:name]} type="text" label="Name for the document" />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          placeholder="Additional details or context"
        />
        <.input field={@form[:issued_at]} type="date" label="Issue date" />
        <.input field={@form[:expires_at]} type="date" label="Expiry date" />
        <.input field={@form[:is_active]} type="checkbox" label="Is this document still valid?" />
        <.input
          field={@form[:invalidation_reason]}
          type="textarea"
          label="Invalidation reason"
          placeholder="Explanation for why the document is no longer valid"
        />
        <.input
          :if={false}
          field={@form[:file_url]}
          type="text"
          label="File URL"
          placeholder="URL or file path to the document file"
        />
        <.input
          :if={false}
          field={@form[:custom_buffer_time_days]}
          type="number"
          label="Lead time for user action (days)"
        />
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
         |> put_toast(:info, "User document updated successfully")
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
         |> put_toast(:info, "User document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
