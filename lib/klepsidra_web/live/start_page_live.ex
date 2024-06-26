defmodule KlepsidraWeb.StartPageLive do
  @moduledoc """
  Klepsidra's home page, where every user is expected to start their
  interaction with the application.

  The 'today' view is available on this page, listing all the timers active
  today, as well as any other pertinent information for daily use.
  """

  use KlepsidraWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
