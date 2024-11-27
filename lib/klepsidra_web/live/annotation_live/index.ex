defmodule KlepsidraWeb.AnnotationLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast

  alias Klepsidra.KnowledgeManagement
  alias Klepsidra.KnowledgeManagement.Annotation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :annotations, KnowledgeManagement.list_annotations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Annotation")
    |> assign(:annotation, KnowledgeManagement.get_annotation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Annotation")
    |> assign(:annotation, %Annotation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Annotations")
    |> assign(:annotation, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.AnnotationLive.FormComponent, {:saved, annotation}}, socket) do
    {:noreply, stream_insert(socket, :annotations, annotation)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    annotation = KnowledgeManagement.get_annotation!(id)
    {:ok, _} = KnowledgeManagement.delete_annotation(annotation)

    {:noreply, handle_deleted_annotation(socket, annotation, :annotations)}
  end

  defp handle_deleted_annotation(socket, annotation, source_stream) do
    socket
    |> stream_delete(source_stream, annotation)
    |> put_toast(:info, "Annotation deleted successfully")
  end
end
