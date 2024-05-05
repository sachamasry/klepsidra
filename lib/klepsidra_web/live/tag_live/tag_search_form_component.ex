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
       form: to_form(changeset)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tag-search">
      <h1 class="mt-8">Find a tag</h1>
      <form phx-submit="tag_search" phx-change="autocomplete">
        <input
          type="text"
          name="search_phrase"
          value={@search_phrase}
          placeholder="Enter tag"
          autofocus
          autocomplete="off"
          phx-debounce="500"
          list="matches"
        />
        <button>Search</button>

        <datalist id="matches">
          <option :for={{id, name} <- @search_results} value={id}>
            <%= name %>
          </option>
        </datalist>
      </form>
    </div>
    """
  end
end
