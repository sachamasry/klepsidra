defmodule KlepsidraWeb.Live.TagLive.SearchFormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag

  @impl true
  def mount(socket) do
    changeset = Categorisation.change_tag(%Tag{})

    {:ok,
     assign(socket,
       search_phrase: "",
       search_results: [],
       current_focus: -1,
       form: to_form(changeset)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tag-search">
      <form phx-submit="submit" phx-change="tag_search" phx-target={@myself}>
        <input
          type="text"
          class="form-control"
          name="search_phrase"
          value={@search_phrase}
          placeholder="Enter tag"
          autofocus
          autocomplete="off"
          phx-debounce="500"
          list="matches"
        />
        <button>Search</button>

        <%!-- <datalist id="matches">
          <option :for={{id, name} <- @search_results} value={id}>
            <%= name %>
          </option>
        </datalist> --%>
      </form>

      <%!-- <div>
        <%= inspect(@search_results) %>
      </div> --%>

      <div class="relative" phx-window-keydown="set-focus" phx-target={@myself}>
        <div class="absolute z-50 left-0 right-0 rounded border-gray-100 shadow py-0 bg-white">
          <div
            :for={{{_id, search_result}, idx} <- Enum.with_index(@search_results)}
            class={"cursor-pointer p-2 hover:bg-gray-200 focus:bg-gray-200 #{if(idx == @current_focus, do: "bg-gray-200")}"}
            phx-click="pick"
            phx-target={@myself}
            phx-value-name={search_result}
          >
            <%= raw(format_search_result(search_result, @search_phrase)) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("tag_search", %{"search_phrase" => search_phrase}, socket) do
    search_results =
      Klepsidra.Categorisation.search_tags_by_name_prefix(search_phrase)
      |> Enum.map(fn tag -> {tag.id, tag.name} end)

    socket =
      assign(socket,
        search_results: search_results,
        search_phrase: search_phrase
      )

    {:noreply, socket}
  end

  def handle_event("pick", %{"name" => search_phrase}, socket) do
    assigns = [
      search_results: [],
      search_phrase: search_phrase
    ]

    {:noreply, assign(socket, assigns)}
  end

  # PREVENT FORM SUBMIT
  def handle_event("submit", _, socket), do: {:noreply, socket}

  # UP
  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    current_focus =
      Enum.max([socket.assigns.current_focus - 1, 0])

    {:noreply, assign(socket, current_focus: current_focus)}
  end

  # DOWN
  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    current_focus =
      Enum.min([socket.assigns.current_focus + 1, length(socket.assigns.search_results) - 1])

    {:noreply, assign(socket, current_focus: current_focus)}
  end

  # ENTER
  def handle_event("set-focus", %{"key" => "Enter"}, socket) do
    case Enum.at(socket.assigns.search_results, socket.assigns.current_focus) do
      {_, "" <> search_phrase} ->
        handle_event("pick", %{"name" => search_phrase}, socket)

      _ ->
        {:noreply, socket}
    end
  end

  # FALLBACK FOR NON RELATED KEY STROKES
  def handle_event("set-focus", _, socket), do: {:noreply, socket}

  def format_search_result(search_result, search_phrase) do
    split_at = String.length(search_phrase)
    {selected, rest} = String.split_at(search_result, split_at)

    "<strong>#{selected}</strong>#{rest}"
  end
end
