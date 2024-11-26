defmodule KlepsidraWeb.DocumentIssuerLive.FormComponent do
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
        id="document_issuer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:country_id]} type="text" label="Country" />
        <.input field={@form[:website_url]} type="url" label="Website URL" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document_issuer: document_issuer} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Documents.change_document_issuer(document_issuer))
     end)}
  end

  @impl true
  def handle_event("validate", %{"document_issuer" => document_issuer_params}, socket) do
    changeset =
      Documents.change_document_issuer(socket.assigns.document_issuer, document_issuer_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"document_issuer" => document_issuer_params}, socket) do
    save_document_issuer(socket, socket.assigns.action, document_issuer_params)
  end

  defp save_document_issuer(socket, :edit, document_issuer_params) do
    case Documents.update_document_issuer(socket.assigns.document_issuer, document_issuer_params) do
      {:ok, document_issuer} ->
        notify_parent({:saved, document_issuer})

        {:noreply,
         socket
         |> put_toast(:info, "Document issuer updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document_issuer(socket, :new, document_issuer_params) do
    case Documents.create_document_issuer(document_issuer_params) do
      {:ok, document_issuer} ->
        notify_parent({:saved, document_issuer})

        {:noreply,
         socket
         |> put_toast(:info, "Document issuer created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
