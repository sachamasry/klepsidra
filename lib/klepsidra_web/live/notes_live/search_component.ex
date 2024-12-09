defmodule KlepsidraWeb.NotesLive.SearchComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [notes: []]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.search_modal :if={@show} id="search-modal" show on_cancel={@on_cancel}>
        <:header_block>
          <.search_input
            placeholder="Search for notes"
            value={@search_query}
            phx-target={@myself}
            phx-keyup="do-search"
            phx-debounce="200"
          />
        </:header_block>
        <.search_results docs={@notes} />
      </.search_modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       notes: [],
       search_query: ""
     )}

    # |> assign_new(
    #   :notes,
    #   fn -> [] end
    # )
    # |> assign_new(:search_query, fn -> "" end)}
  end

  @impl true
  def handle_event("do-search", %{"value" => search_phrase}, socket) do
    search_results =
      if String.length(search_phrase) < 3 do
        []
      else
        search_notes(
          search_phrase,
          []
        )
      end

    socket =
      socket
      |> assign(
        search_phrase: search_phrase,
        notes: search_results
      )

    {:noreply, socket}
  end

  attr(:value, :any)
  attr(:placeholder, :string, default: "Search...")
  attr :rest, :global

  def search_input(assigns) do
    ~H"""
    <div class="relative ">
      <.icon name="hero-magnifying-glass-mini" class="absolute top-1/2 -translate-y-1/2 left-4" />
      <input
        {@rest}
        type="text"
        class="rounded-md h-12 w-full border-none focus:ring-0 pl-12 pr-4 text-gray-800 placeholder-gray-400 sm:text-sm"
        placeholder={@placeholder}
        role="combobox"
        aria-expanded="false"
        aria-controls="options"
      />
    </div>
    """
  end

  attr :docs, :list, required: true

  def search_results(assigns) do
    ~H"""
    <ul class="-mb-2 py-2 text-sm text-gray-800 flex space-y-3 flex-col" id="options" role="listbox">
      <li
        :if={@docs == []}
        id="option-none"
        role="option"
        tabindex="-1"
        class="cursor-default select-none rounded-md px-4 py-2 text-xl"
      >
        No Results
      </li>

      <.link
        :for={doc <- @docs}
        navigate={~p"/knowledge_management/notes/#{doc.id}"}
        id={"doc-#{doc.id}"}
      >
        <.result_item doc={doc} />
      </.link>
    </ul>
    """
  end

  attr :doc, :map, required: true

  def result_item(assigns) do
    ~H"""
    <li
      class="group cursor-default select-none rounded-md px-4 py-2 text-xl bg-peach-fuzz-lightness-38 hover:bg-peach-fuzz-600 hover:text-white hover:cursor-pointer flex flex-row space-x-2 items-center"
      id={"option-#{@doc.id}"}
      role="option"
      tabindex="-1"
    >
      <!-- svg of a document -->
      <div>
        <%= @doc.title %>
        <div :if={@doc.summary} class="text-sm"><%= @doc.summary %></div>
        <div class="text-xs"><%= @doc.result |> Phoenix.HTML.raw() %></div>
      </div>
    </li>
    """
  end

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :header_block
  slot :inner_block, required: true

  def search_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="modal-component__backdrop bg-peach-fuzz-lightness-25/90 fixed inset-0 bg-zinc-50/90 transition-opacity"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full justify-center border-peach-fuzz-300">
          <div class="w-full min-h-12 max-w-3xl p-2 sm:p-4 lg:py-6">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl shadow-lg bg-peach-fuzz-lightness-88 shadow-peach-fuzz-300/20 ring-1 ring-peach-fuzz-300/30 transition min-h-[30vh] max-h-[90vh]"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-60"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="bg-peach-fuzz-500 h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"} class="flex flex-col">
                <header class="basis-auto grow-0 shrink-0 px-14 pt-14 pb-5 border-b border-peach-fuzz-300/50">
                  <%= render_slot(@header_block) %>
                </header>
                <div class="flex-auto px-14 py-6 max-h-[70vh] overflow-y-auto">
                  <%= render_slot(@inner_block) %>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp search_notes(search_phrase, _default) when is_bitstring(search_phrase) do
    # try do
    Klepsidra.KnowledgeManagement.search_notes_and_highlight_snippet(search_phrase)
    # rescue
    #   Exqlite.Error ->
    #     default
    # end
  end

  # defp search_notes(_, default), do: default
end
