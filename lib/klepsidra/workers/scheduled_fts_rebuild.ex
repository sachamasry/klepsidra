defmodule Klepsidra.Workers.ScheduledFtsRebuildWorker do
  @moduledoc """
  Oban worker triggering a full, full-text search (FTS) index
  rebuild.

  Note: this worker is scheduled on an hourly basis, as a reliable
  index rebuilder, until one of several solutions detecting database
  changes is implemented.
  """

  use Oban.Worker,
    queue: :default,
    priority: 5,
    max_attempts: 1

  alias Klepsidra.Search

  @impl Oban.Worker
  def perform(_job) do
    Search.rebuild_fts_index()
    :ok
  end
end
