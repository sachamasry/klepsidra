defmodule KlepsidraWeb.AnnotationLive.Show do
  @moduledoc false

  use KlepsidraWeb, :live_view

  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.KnowledgeManagement

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:annotation, KnowledgeManagement.get_annotation!(id))}
  end

  defp page_title(:show), do: "Show Annotation"
  defp page_title(:edit), do: "Edit Annotation"
end
