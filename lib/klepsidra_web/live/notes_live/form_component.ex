defmodule KlepsidraWeb.NotesLive.FormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  import LiveToast

  alias Klepsidra.Categorisation
  alias Klepsidra.DynamicCSS
  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.Repo
  alias Klepsidra.Categorisation.Tag
  alias KlepsidraWeb.TagLive.TagUtilities

  @tag_search_live_component_id "note_ls_tag_search_live_select_component"

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
        id="notes-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />

        <div id="tag-selector" class={"flex #{if @selected_tag_queue != [], do: "gap-2"}"}>
          <div
            id="tag-selector__live-select"
            phx-mounted={JS.add_class("hidden", to: "#note_ls_tag_search_text_input")}
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

        <.input field={@form[:content]} type="textarea" label="Note content" />
        <.input
          field={@form[:content_format]}
          type="select"
          label="Content format"
          prompt="Choose a value"
          selected="markdown"
          options={Ecto.Enum.values(Klepsidra.KnowledgeManagement.Note, :content_format)}
        />
        <.input field={@form[:summary]} type="text" label="Summary" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          selected="fleeting"
          options={Ecto.Enum.values(Klepsidra.KnowledgeManagement.Note, :status)}
        />
        <.input field={@form[:review_date]} type="date" label="Review date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save note</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{note: note} = assigns, socket) do
    note = note |> Repo.preload(:tags)

    socket =
      socket
      |> TagUtilities.generate_tag_options(
        [],
        Enum.map(note.tags, fn tag -> tag.id end),
        @tag_search_live_component_id
      )
      |> Phx.Live.Head.push_content(
        "style[id*=dynamic-style-block]",
        :set,
        DynamicCSS.generate_tag_styles(note.tags)
      )
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(KnowledgeManagement.change_note(note))
      end)
      |> assign(new_tag_colour: {"#94a3b8", "#fff"})

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["note", "ls_tag_search"],
          "note" => %{"ls_tag_search" => tags_applied}
        },
        socket
      ) do
    parent_tag_select_id = Map.get(socket.assigns, :parent_tag_select_id, nil)

    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      tags_applied,
      socket.assigns.note.id,
      &KnowledgeManagement.add_knowledge_management_note_tag(&1, &2),
      &KnowledgeManagement.delete_knowledge_management_note_tag(&1, &2)
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
          "_target" => ["note", "ls_tag_search_empty_selection"],
          "note" => %{"ls_tag_search_empty_selection" => ""}
        },
        socket
      ) do
    parent_tag_select_id = Map.get(socket.assigns, :parent_tag_select_id, nil)

    Tag.handle_tag_list_changes(
      socket.assigns.selected_tag_queue,
      [],
      socket.assigns.note.id,
      &KnowledgeManagement.add_knowledge_management_note_tag(&1, &2),
      &KnowledgeManagement.delete_knowledge_management_note_tag(&1, &2)
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
          "_target" => ["note", "bg_colour"],
          "note" => %{
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

  @impl true
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset = KnowledgeManagement.change_note(socket.assigns.note, note_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    save_note(socket, socket.assigns.action, note_params)
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{
          "field" => "note_ls_tag_search",
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

  defp save_note(socket, :edit, note_params) do
    case KnowledgeManagement.update_note(socket.assigns.note, note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_toast(:info, "Note updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_note(socket, :new, note_params) do
    case KnowledgeManagement.create_note(note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_toast(:info, "Note created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp enable_tag_selector() do
    JS.remove_class("hidden", to: "#note_ls_tag_search_text_input")
    |> JS.remove_class("hidden", to: "#tag-selector__colour-select")
    |> JS.add_class("hidden", to: "#tag-selector__add-button")
    |> JS.add_class("gap-2", to: "#tag-selector")
    |> JS.add_class("flex-auto", to: "#tag-selector__live-select")
    |> JS.focus(to: "#note_ls_tag_search_text_input")
  end
end
