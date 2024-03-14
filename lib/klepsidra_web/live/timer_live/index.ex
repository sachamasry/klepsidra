defmodule KlepsidraWeb.TimerLive.Index do
  use KlepsidraWeb, :live_view

  alias Klepsidra.TimeTracking
  alias Klepsidra.TimeTracking.Timer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :timers, TimeTracking.list_timers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit")
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :stop, %{"id" => id}) do
    socket
    |> assign(:page_title, "Clock out")
    |> assign(:clocked_out, Klepsidra.TimeTracking.Timer.clock_out(TimeTracking.get_timer!(id).start_stamp, :minute))
    |> assign(:timer, TimeTracking.get_timer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Manual Timer")
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :start, _params) do
    socket
    |> assign(:page_title, "Starting Timer")
    |> assign(:start_timestamp, Klepsidra.TimeTracking.Timer.get_current_timestamp())
    |> assign(:timer, %Timer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Acitivity Timers")
    |> assign(:timer, nil)
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.FormComponent, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :timers, timer)}
  end

  @impl true
  def handle_info({KlepsidraWeb.TimerLive.AutomatedTimer, {:saved, timer}}, socket) do
    {:noreply, stream_insert(socket, :timers, timer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    timer = TimeTracking.get_timer!(id)
    {:ok, _} = TimeTracking.delete_timer(timer)

    {:noreply, stream_delete(socket, :timers, timer)}
  end
end
