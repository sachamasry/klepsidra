defmodule Mix.Tasks.RebuildFtsIndex do
  use Mix.Task

  @shortdoc "Rebuild the global full-text search (FTS) index for the application"

  @moduledoc """
  Tasks defined here operate on SQLite virtual tables, defined for indexing
  information for full-text search, externally initiating the [re]building and
  generation of these indexes.
  """

  @requirements ["app.start"]

  @doc """
  Rebuild the global unified search FTS index.
  """
  @impl Mix.Task
  def run(_) do
    Mix.Task.run("app.start")
    Klepsidra.Search.rebuild_fts_index()
    IO.puts("FTS5 index rebuilt successfully.")
  end
end
