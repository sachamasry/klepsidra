defmodule KlepsidraWeb.SearchPageLive do
  @moduledoc """
  Klepsidra's search page, where every entity can be searched using a
  unified search interface to all the application's entities.
  """

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  alias KlepsidraWeb.SearchLive.SearchComponent

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Search
      <:actions>
        <.outline_button phx-click={JS.push("search", value: %{show_search: true})}>
          <.icon name="hero-magnifying-glass" /> Search
        </.outline_button>
      </:actions>
    </.header>

    <div>
      <.live_component
        module={SearchComponent}
        id="search-results"
        show={@show_search}
        on_cancel={JS.push("search", value: %{show_search: false})}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(show_search: false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("search", %{"show_search" => show_search}, socket) do
    socket =
      socket
      |> assign(show_search: show_search)

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end
end
