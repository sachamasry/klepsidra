defmodule KlepsidraWeb.TagLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents
  import LiveToast

  alias Klepsidra.Categorisation
  alias Klepsidra.Categorisation.Tag

  # alias KlepsidraWeb.Live.TagLive.SearchFormComponent

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
  def handle_event("delete", %{"id" => id}, socket) do
    tag = Categorisation.get_tag!(id)
    {:ok, _} = Categorisation.delete_tag(tag)

    {:noreply, handle_deleted_tag(socket, tag, :tags)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit tag")
    |> assign(:tag, Categorisation.get_tag!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New tag")
    |> assign(:tag, %Tag{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Tags")
    |> assign(:tag, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.TagLive.FormComponent, {:saved, tag}}, socket) do
    {:noreply, stream_insert(socket, :tags, tag)}
  end

  defp handle_deleted_tag(socket, tag, source_stream) do
    socket
    |> stream_delete(source_stream, tag)
    |> put_toast(:info, "Tag deleted successfully")
  end
end
