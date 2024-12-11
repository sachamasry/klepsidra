defmodule KlepsidraWeb.RelationshipTypeLive.Show do
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
     |> assign(:relationship_type, KnowledgeManagement.get_relationship_type!(id))}
  end

  defp page_title(:show), do: "Show relationship type"
  defp page_title(:edit), do: "Edit relationship type"
end
