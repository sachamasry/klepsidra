defmodule KlepsidraWeb.ActivityTypeLive.Index do
  @moduledoc false

  use KlepsidraWeb, :live_view
  import LiveToast
  import KlepsidraWeb.ButtonComponents

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.ActivityType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :activity_types, TimeTracking.list_activity_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit activity type")
    |> assign(:activity_type, TimeTracking.get_activity_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New activity type")
    |> assign(:activity_type, %ActivityType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Activity types")
    |> assign(:activity_type, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.ActivityTypeLive.FormComponent, {:saved, activity_type}}, socket) do
    {:noreply, stream_insert(socket, :activity_types, activity_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity_type = TimeTracking.get_activity_type!(id)
    {:ok, _} = TimeTracking.delete_activity_type(activity_type)

    {:noreply, handle_deleted_activity_type(socket, activity_type, :activity_types)}
  end

  defp handle_deleted_activity_type(socket, activity_type, source_stream) do
    socket
    |> stream_delete(source_stream, activity_type)
    |> put_toast(:info, "Activity type deleted successfully")
  end
end
