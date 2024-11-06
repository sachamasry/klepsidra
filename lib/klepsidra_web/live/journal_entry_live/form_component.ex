defmodule KlepsidraWeb.JournalEntryLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntryTypes
  alias Klepsidra.Locations.City

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle :if={@action == :new}>What did you do today?</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="journal_entry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          :if={@action == :new}
          field={@form[:journal_for]}
          type="date"
          label="Journal for"
          value={@datestamp}
        />
        <.input :if={@action == :edit} field={@form[:journal_for]} type="date" label="Journal for" />
        <.input field={@form[:entry_type_id]} type="select" label="Entry type" options={@entry_types} />
        <.input
          field={@form[:entry_text_markdown]}
          type="textarea"
          label="Journal entry"
          phx-debounce="1500"
        />
        <.input
          field={@form[:highlights]}
          type="text"
          label="Key takeaways or highlights"
          placeholder="Summary of key points"
        />
        <.input field={@form[:mood]} type="text" label="How would you describe your mood?" />
        <.live_select
          field={@form[:location_id]}
          mode={:single}
          label="Location"
          options={[]}
          placeholder="Where are you?"
          debounce={200}
          dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
          update_min_len={2}
          value_mapper={&value_mapper/1}
          phx-focus="location_focus"
          phx-blur="location_blur"
          phx-target={@myself}
        >
          <:option :let={option}>
            <div class="flex">
              <%= option.label %>
            </div>
          </:option>
        </.live_select>

        <.input field={@form[:is_private]} type="checkbox" label="Private entry?" />
        <:actions>
          <.button phx-disable-with="Saving...">Save journal entry</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{journal_entry: journal_entry} = assigns, socket) do
    # if journal_entry.id do
    # send_update(LiveSelect.Component,
    #             id: "journal_entry_location_id_live_select_component",
    #             options: City.format_city_into_html_select("63de1fac-95d0-49f2-a2bf-11740a5950c1")
    # )
    # end

    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Journals.change_journal_entry(journal_entry))
      end)
      |> assign_entry_type()
      |> assign(:location_select_value, %{
        label: "West End of London, England - United Kingdom",
        value: "63de1fac-95d0-49f2-a2bf-11740a5950c1"
      })

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"journal_entry" => journal_entry_params}, socket) do
    changeset =
      socket.assigns.journal_entry
      |> Journals.change_journal_entry(journal_entry_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"journal_entry" => journal_entry_params}, socket) do
    save_journal_entry(socket, socket.assigns.action, journal_entry_params)
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    cities = Klepsidra.Locations.city_search(text)

    send_update(LiveSelect.Component, id: live_select_id, options: cities)

    {:noreply, socket}
  end

  def handle_event("focus", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("clear", %{"id" => id}, socket) do
    send_update(LiveSelect.Component, options: [], id: id)

    {:noreply, socket}
  end

  def handle_event("location_focus", %{"id" => _id}, socket) do
    {:noreply, socket}
  end

  def handle_event("location_blur", %{"id" => _id}, socket) do
    {:noreply, socket}
  end

  defp save_journal_entry(socket, :edit, journal_entry_params) do
    case Journals.update_journal_entry(socket.assigns.journal_entry, journal_entry_params) do
      {:ok, journal_entry} ->
        journal_entry =
          [journal_entry | []]
          |> Klepsidra.Journals.preload_journal_entry_type()
          |> List.first()

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
        journal_entry =
          [journal_entry | []]
          |> Klepsidra.Journals.preload_journal_entry_type()
          |> List.first()

        notify_parent({:saved, journal_entry})

        {:noreply,
         socket
         |> put_flash(:info, "Journal entry logged successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @spec assign_entry_type(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  defp assign_entry_type(socket) do
    entry_types = JournalEntryTypes.populate_entry_types_list()

    assign(socket, entry_types: entry_types)
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp value_mapper(location_id) when is_bitstring(location_id) do
    City.city_option_for_select(location_id)
  end

  defp value_mapper(value), do: value
end
