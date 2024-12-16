defmodule KlepsidraWeb.SearchLive.SearchComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component

  alias Klepsidra.Search

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [entities: []]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="document-search-container">
      <.search_modal :if={@show} id="search-modal" show on_cancel={@on_cancel}>
        <:header_block>
          <.search_input
            placeholder="Searc "
            value={@search_query}
            phx-target={@myself}
            phx-keyup="do-search"
            phx-debounce="200"
          />
        </:header_block>
        <.search_results docs={@entities} />
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
       entities: [],
       search_query: ""
     )}
  end

  @impl true
  def handle_event("do-search", %{"value" => search_phrase}, socket) do
    search_results =
      if String.length(search_phrase) < 3 do
        []
      else
        search_entities(
          search_phrase,
          []
        )
      end

    socket =
      socket
      |> assign(
        search_phrase: search_phrase,
        entities: search_results
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
    <ul class="-mb-2 py-2 text-sm text-gray-800 flex space-y-2 flex-col" id="options" role="listbox">
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
      <.icon name="hero-document-text" class="basis-5 shrink-0 grow-0 h-5 w-5" />
      <div>
        <div class="text-lg font-semibold leading-6 text-slate-700 group-hover:text-white group-hover:font-bold">
          <%= @doc.title %>
        </div>
        <div :if={@doc.subtitle} class="text-base leading-6"><%= @doc.subtitle %></div>
        <div class="text-sm leading-6 italic"><%= @doc.result |> Phoenix.HTML.raw() %></div>
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
              class="hidden relative rounded-2xl shadow-lg bg-peach-fuzz-lightness-88 shadow-peach-fuzz-300/20 ring-1 ring-peach-fuzz-300/30 transition min-h-[30vh] max-h-[90vh] py-6"
            >
              <div class="absolute top-8 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-60"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="bg-peach-fuzz-500 h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"} class="search-results flex flex-col">
                <header class="search-results__header basis-auto grow-0 shrink-0 px-14 pb-5 border-b border-peach-fuzz-300/50">
                  <%= render_slot(@header_block) %>
                </header>
                <div class="search-results__body flex-auto px-14 py-6 max-h-[70vh] overflow-y-auto">
                  <%= render_slot(@inner_block) %>
                </div>
                <footer class="search-results__footer flex-auto px-14 py-6 border-t border-peach-fuzz-300/50 max-h-[20vh] overflow-y-auto">
                  <details>
                    <summary class="text-violet-900">Advanced search suggestions</summary>
                    <details>
                      <summary>Searching for phrase nearness</summary>
                      <p>
                        To search for specific phrases which appear close to each other, use a
                        <strong>NEAR</strong>
                        query.
                      </p>
                      <code>NEAR("phrase 1" "phrase 2", distance)</code>
                      <p>
                        Where <em>phrase 1</em>
                        and <em>phrase 2</em>
                        can be single words or actual phrases of multiple words. You can use as many phrases as needed, in double quotation marks. Use
                        <em>distance</em>
                        to specify maximum number of letters separating the phrases.
                      </p>
                    </details>
                    <details>
                      <summary>Searching by column</summary>
                    </details>
                    <details>
                      <summary>Boolean operators</summary>
                    </details>
                  </details>
                </footer>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp search_entities(search_phrase, default) when is_bitstring(search_phrase) do
    try do
      Search.search_and_highlight_snippet(search_phrase)
    rescue
      Exqlite.Error ->
        default
    end
  end
end
