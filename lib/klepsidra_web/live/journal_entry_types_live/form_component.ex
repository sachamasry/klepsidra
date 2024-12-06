defmodule KlepsidraWeb.JournalEntryTypesLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  import LiveToast

  alias Klepsidra.Journals

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
        id="journal_entry_types-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{journal_entry_types: journal_entry_types} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Journals.change_journal_entry_types(journal_entry_types))
     end)}
  end

  @impl true
  def handle_event("validate", %{"journal_entry_types" => journal_entry_types_params}, socket) do
    changeset =
      Journals.change_journal_entry_types(
        socket.assigns.journal_entry_types,
        journal_entry_types_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"journal_entry_types" => journal_entry_types_params}, socket) do
    save_journal_entry_types(socket, socket.assigns.action, journal_entry_types_params)
  end

  defp save_journal_entry_types(socket, :edit, journal_entry_types_params) do
    case Journals.update_journal_entry_types(
           socket.assigns.journal_entry_types,
           journal_entry_types_params
         ) do
      {:ok, journal_entry_types} ->
        notify_parent({:saved, journal_entry_types})

        {:noreply,
         socket
         |> put_toast(:info, "Journal entry type updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_journal_entry_types(socket, :new, journal_entry_types_params) do
    case Journals.create_journal_entry_types(journal_entry_types_params) do
      {:ok, journal_entry_types} ->
        notify_parent({:saved, journal_entry_types})

        {:noreply,
         socket
         |> put_toast(:info, "Journal entry type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
