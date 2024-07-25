defmodule KlepsidraWeb.ProjectLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast

  alias Klepsidra.Projects
  alias Klepsidra.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :projects, Projects.list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, handle_deleted_project(socket, project, :projects)}
  end

  defp handle_deleted_project(socket, proiect, source_stream) do
    socket
    |> stream_delete(source_stream, proiect)
    |> put_toast(:info, "Project deleted successfully")
  end
end
