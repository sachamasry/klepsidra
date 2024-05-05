defmodule KlepsidraWeb.TagLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag

  alias KlepsidraWeb.Live.TagLive.SearchFormComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        search_phrase: "",
        filtered_tags: [],
        matches: []
      )

    {:ok, stream(socket, :tags, Categorisation.list_tags())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("autocomplete", %{"search_phrase" => search_phrase}, socket) do
    matches =
      Klepsidra.Categorisation.search_tags_by_name_prefix(search_phrase)
      |> Enum.map(fn tag -> {tag.id, tag.name} end)

    socket =
      assign(socket,
        matches: matches
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("tag_search", %{"search_phrase" => search_phrase}, socket) do
    socket =
      assign(socket,
        search_phrase: search_phrase,
        filtered_tags: Klepsidra.Categorisation.search_tags_by_name_prefix(search_phrase)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tag = Categorisation.get_tag!(id)
    {:ok, _} = Categorisation.delete_tag(tag)

    {:noreply, stream_delete(socket, :tags, tag)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tag")
    |> assign(:tag, Categorisation.get_tag!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tag")
    |> assign(:tag, %Tag{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tags")
    |> assign(:tag, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.TagLive.FormComponent, {:saved, tag}}, socket) do
    {:noreply, stream_insert(socket, :tags, tag)}
  end
end
