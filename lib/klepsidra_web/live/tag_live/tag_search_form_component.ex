defmodule KlepsidraWeb.Live.TagLive.SearchFormComponent do
  @moduledoc false

  use KlepsidraWeb, :live_component
  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag
  alias Klepsidra.TimeTracking

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tag-search">
      <%!-- <form phx-submit="submit" phx-change="tag_search" phx-target={@myself}>
        <input
          type="text"
          class="form-control"
          name="search_phrase"
          value={@search_phrase}
          placeholder="Enter tag"
          autocomplete="off"
          phx-debounce="500"
          list="matches"
        /> --%>
      <%!-- <button>Search</button> --%>

      <%!-- <datalist id="matches">
          <option :for={{id, name} <- @search_results} value={id}>
            <%= name %>
          </option>
        </datalist> --%>
      <%!-- </form> --%>

      <%!-- <div>
        <%= inspect(@search_results) %>
      </div> --%>

      <%!-- <div class="relative" phx-window-keydown="set-focus" phx-target={@myself}>
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
      </div> --%>

      <form phx_submit="submit" phx_change="tag_search" phx-target={@myself}>
        <div
          class="py-2 px-3 bg-white border border-gray-400"
          phx-window-keydown="set-focus"
          phx-target={@myself}
        >
          <span
            :for={timer_tag <- @timer_tags}
            class="inline-block text-xs bg-green-400 text-white py-1 px-2 mr-1 mb-1 rounded"
          >
            <%!-- <span><%= timer_tag.tag.name %></span> --%>
            <div><%= inspect(timer_tag, pretty: true) %></div>
            <a
              href="#"
              class="text-white hover:text-white"
              phx-click="delete"
              phx-target={@myself}
              phx-value-timer-tag-id={timer_tag.id}
            >
              &times;
            </a>
          </span>

          <input
            type="text"
            class="form-control inline-block text-sm focus:outline-none"
            name="search_phrase"
            value={@search_phrase}
            placeholder="Enter tag"
            autocomplete="off"
            phx-change="tag_search"
            phx-debounce="500"
          />
        </div>

        <div :if={@search_results != []} class="relative">
          <div class="absolute z-50 left-0 right-0 rounded border border-gray-100 shadow py-1 bg-white">
            <div
              :for={{{_id, search_result}, idx} <- Enum.with_index(@search_results)}
              class={"cursor-pointer p-2 hover:bg-gray-200 focus:bg-gray-200 #{if(idx == @current_focus, do: "bg-gray-200")}"}
              phx-submit="sbmt"
              phx-click="pick"
              phx-target={@myself}
              phx-value-name={search_result}
            >
              <%= raw(format_search_result(search_result, @search_phrase)) %>
            </div>
          </div>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    timer = TimeTracking.get_timer!(assigns.timer_id) |> Klepsidra.Repo.preload(:tags)

    changeset = Categorisation.change_tag(%Tag{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       timer: timer,
       timer_tags: sort_tags(timer.timer_tags),
       tags: [],
       search_results: [],
       search_phrase: "",
       current_focus: -1,
       form: to_form(changeset)
     )}
  end

  @impl true
  def handle_event("tag_search", %{"search_phrase" => search_phrase}, socket) do
    tags = if socket.assigns.tags == [], do: Categorisation.list_tags(), else: socket.assigns.tags

    search_results =
      Klepsidra.Categorisation.search_tags_by_name_prefix(search_phrase)
      |> Enum.map(fn tag -> {tag.id, tag.name} end)

    # search_results = search(tags, search_phrase)

    socket =
      assign(socket,
        tags: tags,
        search_results: search_results,
        search_phrase: search_phrase
      )

    {:noreply, socket}
  end

  def handle_event("pick", %{"name" => search_phrase}, socket) do
    timer = socket.assigns.timer
    timer_tags = add_tag_to_timer(timer, search_phrase)

    # IO.inspect(timer_tags, label: "Timer tags")

    assigns = [
      timer_tags: sort_tags(timer_tags),
      tags: [],
      search_results: [],
      search_phrase: ""
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("delete", %{"timer-tag-id" => timer_tag_id}, socket) do
    # IO.inspect(timer_tag_id, label: "timer_tag_id")
    # IO.inspect(socket.assigns, label: "Delete assigns")
    # timer_tags = delete_tag_from_timer(socket.assigns, timer_tag_id)

    # IO.inspect(socket.assigns.timer_tags, label: "timer_tags before deletion")
    # timer_tags =
    delete_tag_from_timer(timer_tag_id)

    # IO.inspect(timer_tags, label: "timer_tags ")
    # IO.inspect(socket.assigns.timer_tags, label: "timer_tags after deletion")
    assigns = [
      # timer_tags: timer_tags,
      tags: [],
      search_results: [],
      search_phrase: ""
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

  # defp search(_, ""), do: []

  # defp search(tags, search_phrase) do
  #   tags
  #   |> Enum.map(fn tag -> tag.name end)
  #   |> Enum.sort()
  #   |> Enum.filter(fn tags -> matches?(tags, search_phrase) end)
  # end

  # defp matches?(first, second) do
  #   String.starts_with?(
  #     String.downcase(first),
  #     String.downcase(second)
  #   )
  # end

  def format_search_result(search_result, search_phrase) do
    split_at = String.length(search_phrase)
    {selected, rest} = String.split_at(search_result, split_at)

    "<strong>#{selected}</strong>#{rest}"
  end

  defp add_tag_to_timer(timer, search_phrase) do
    Categorisation.tag_timer(timer, %{tag: %{name: search_phrase}})
    timer = TimeTracking.get_timer!(timer.id) |> Klepsidra.Repo.preload(:tags)

    timer.tags
  end

  # defp delete_tag_from_timer(%{timer: timer, timer_tags: timer_tags}, timer_tag_id) do
  defp delete_tag_from_timer(timer_tag_id) do
    # timer_tags
    # |> dbg
    # |> Enum.reject(fn tag ->
    #   if "#{tag.id}" == timer_tag_id do
    #     Categorisation.delete_tag_from_timer(timer, tags.tag)
    #     true
    #   else
    #     false
    #   end
    # end)

    # Klepsidra.Repo.get_by!(TimerTags, id: String.to_integer(timer_tag_id))

    {:ok, timer_tag} =
      timer_tag_id
      |> Categorisation.get_timer_tag!()
      |> Categorisation.delete_timer_tag()

    # IO.inspect(timer_tag, label: "timer_tag deleted")
    timer_tag
  end

  defp sort_tags(timer_tags) do
    Enum.sort_by(timer_tags, fn tag -> tag.id end)
  end
end
