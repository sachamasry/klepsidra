defmodule KlepsidraWeb.JournalEntryLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntryTypes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage journal_entry records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="journal_entry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:journal_for]}
          type="date"
          label="Date the journal is for"
          value={@datestamp}
        />
        <.input field={@form[:entry_text_markdown]} type="text" label="Entry text markdown" />
        <.input field={@form[:entry_text_html]} type="text" label="Entry text html" />
        <.input field={@form[:mood]} type="text" label="Mood" />
        <.input field={@form[:is_private]} type="checkbox" label="Is private" />
        <.input field={@form[:is_short_entry]} type="checkbox" label="Is short entry" />
        <.input field={@form[:entry_type_id]} type="select" label="Entry type" options={@entry_types} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Journal entry</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{journal_entry: journal_entry} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Journals.change_journal_entry(journal_entry))
      end)
      |> assign_entry_type()

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"journal_entry" => journal_entry_params}, socket) do
    changeset = Journals.change_journal_entry(socket.assigns.journal_entry, journal_entry_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"journal_entry" => journal_entry_params}, socket) do
    save_journal_entry(socket, socket.assigns.action, journal_entry_params)
  end

  defp save_journal_entry(socket, :edit, journal_entry_params) do
    case Journals.update_journal_entry(socket.assigns.journal_entry, journal_entry_params) do
      {:ok, journal_entry} ->
        notify_parent({:saved, journal_entry})

        {:noreply,
         socket
         |> put_flash(:info, "Journal entry updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_journal_entry(socket, :new, journal_entry_params) do
    case Journals.create_journal_entry(journal_entry_params) do
      {:ok, journal_entry} ->
        notify_parent({:saved, journal_entry})

        {:noreply,
         socket
         |> put_flash(:info, "Journal entry created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # @spec assign_project(Phoenix.LiveView.Socket.t()) :: [Klepsidra.Projects.Project.t(), ...]
  defp assign_entry_type(socket) do
    entry_types = JournalEntryTypes.populate_entry_types_list()

    assign(socket, entry_types: entry_types)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
