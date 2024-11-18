defmodule KlepsidraWeb.JournalEntryLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.Journals
  alias Klepsidra.Journals.JournalEntryTypes
  alias Klepsidra.Locations.City
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities
  alias Klepsidra.DynamicCSS

  @tag_search_live_component_id "journal_entry_ls_tag_search_live_select_component"

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
        phx-window-keyup="key_up"
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

        <div id="tag-selector" class={"flex #{if @selected_tag_queue != [], do: "gap-2"}"}>
          <div
            id="tag-selector__live-select"
            phx-mounted={JS.add_class("hidden", to: "#journal_entry_ls_tag_search_text_input")}
          >
            <.live_select
              field={@form[:ls_tag_search]}
              mode={:tags}
              label=""
              options={[]}
              placeholder="Add tag"
              debounce={80}
              clear_tag_button_class="cursor-pointer px-1 rounded-r-md"
              dropdown_extra_class="bg-white max-h-48 overflow-y-scroll"
              tag_class="bg-slate-400 text-white flex rounded-md text-sm font-semibold"
              tags_container_class="flex flex-wrap gap-2"
              container_extra_class="rounded border border-none"
              update_min_len={1}
              user_defined_options="true"
              value={@selected_tags}
              phx-blur="ls_tag_search_blur"
              phx-target={@myself}
            >
              <:option :let={option}>
                <div class="flex" title={option.description}>
                  <%= option.label %>
                </div>
              </:option>
              <:tag :let={option}>
                <div class={"#{option.tag_class} py-1.5 px-3 rounded-l-md"} title={option.description}>
                  <.link navigate={~p"/tags/#{option.value}"}>
                    <%= option.label %>
                  </.link>
                </div>
              </:tag>
            </.live_select>
          </div>

          <div
            id="tag-selector__colour-select"
            class="tag-colour-picker hidden w-10 overflow-hidden self-end shrink-0"
          >
            <.input field={@form[:bg_colour]} type="color" value={elem(@new_tag_colour, 0)} />
          </div>

          <.button
            id="tag-selector__add-button"
            class="add-tag-button flex-none flex-grow-0 h-fit self-end [&&]:bg-violet-50 [&&]:text-indigo-900 [&&]:py-1 rounded-md"
            type="button"
            phx-click={enable_tag_selector()}
          >
            Add tag +
          </.button>
        </div>

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
    journal_entry = journal_entry |> Klepsidra.Repo.preload(:tags)

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(journal_entry.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(journal_entry.tags)
      )
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Journals.change_journal_entry(journal_entry))
      end)
      |> assign(new_tag_colour: {"#94a3b8", "#fff"})
      |> assign_entry_type()

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["journal_entry", "ls_tag_search"],
          "journal_entry" => %{"ls_tag_search" => tags_applied}
        },
        socket
      ) do
    parent_tag_select_id = Map.get(socket.assigns, :parent_tag_select_id, nil)

    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      tags_applied,
      socket.assigns.journal_entry.id,
      &Categorisation.add_journal_entry_tag(&1, &2),
      &Categorisation.delete_journal_entry_tag(&1, &2)
    )

    socket =
      TagUtilities.generate_tag_options(
        socket,
        socket.assigns.selected_tag_queue,
        tags_applied,
        @tag_search_live_component_id,
        parent_tag_select_id: parent_tag_select_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(tags_applied)
      )
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  @doc """
  Validate event which fires only once the last of the tags has been cleared
  from a `live_select` component.
  """
  def handle_event(
        "validate",
        %{
          "_target" => ["journal_entry", "ls_tag_search_empty_selection"],
          "journal_entry" => %{"ls_tag_search_empty_selection" => ""}
        },
        socket
      ) do
    parent_tag_select_id = Map.get(socket.assigns, :parent_tag_select_id, nil)

    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      [],
      socket.assigns.journal_entry.id,
      &Categorisation.add_journal_entry_tag(&1, &2),
      &Categorisation.delete_journal_entry_tag(&1, &2)
    )

    parent_tag_select_id &&
      send_update(LiveSelect.Component, id: parent_tag_select_id, value: [])

    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{
          "_target" => ["journal_entry", "bg_colour"],
          "journal_entry" => %{
            "bg_colour" => bg_colour
          }
        },
        socket
      ) do
    fg_colour =
      case ColorContrast.calc_contrast(bg_colour) do
        {:ok, fg_colour} -> fg_colour
        {:error, _} -> "#fff"
      end

    socket =
      socket
      |> assign(new_tag_colour: {bg_colour, fg_colour})

    {:noreply, socket}
  end

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
  def handle_event(
        "live_select_change",
        %{
          "field" => "journal_entry_ls_tag_search",
          "id" => live_select_id,
          "text" => tag_search_phrase
        },
        socket
      ) do
    tag_search_results =
      Categorisation.search_tags_by_name_content(tag_search_phrase)
      |> TagUtilities.tag_options_for_live_select()

    send_update(LiveSelect.Component, id: live_select_id, options: tag_search_results)

    socket =
      socket
      |> assign(
        tag_search_phrase: tag_search_phrase,
        possible_free_tag_entered: true
      )

    {:noreply, socket}
  end

  def handle_event(
        "ls_tag_search_blur",
        %{"id" => @tag_search_live_component_id},
        socket
      ) do
    socket =
      socket
      |> assign(
        tag_search_phrase: nil,
        possible_free_tag_entered: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "key_up",
        %{"key" => "Enter"},
        %{assigns: %{tag_search_phrase: tag_search_phrase, possible_free_tag_entered: true}} =
          socket
      ) do
    socket =
      TagUtilities.handle_free_tagging(
        socket,
        tag_search_phrase,
        String.length(tag_search_phrase),
        @tag_search_live_component_id,
        socket.assigns.new_tag_colour
      )

    {:noreply, socket}
  end

  def handle_event("key_up", %{"key" => _}, socket), do: {:noreply, socket}

  def handle_event(
        "live_select_change",
        %{
          "field" => "journal_entry_location_id",
          "id" => live_select_id,
          "text" => text
        },
        socket
      ) do
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

        Tag.handle_tag_list_changes(
          [],
          socket.assigns.selected_tag_queue,
          journal_entry.id,
          &Categorisation.add_journal_entry_tag(&1, &2),
          &Categorisation.delete_journal_entry_tag(&1, &2)
        )

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

  defp enable_tag_selector() do
    JS.remove_class("hidden", to: "#journal_entry_ls_tag_search_text_input")
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select")
    |> JS.add_class("hidden", to: "#tag-selector__add-button")
    |> JS.add_class("gap-2", to: "#tag-selector")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select")
    |> JS.focus(to: "#journal_entry_ls_tag_search_text_input")
  end
end
