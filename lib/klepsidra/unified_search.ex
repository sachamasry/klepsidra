defmodule Klepsidra.Search do
  @moduledoc """
  The unified search context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.Search.UnifiedSearch

  @type exqlite_result :: %Exqlite.Result{
          columns: [String.t()] | nil,
          command: atom(),
          num_rows: integer(),
          rows: [[term()] | term()] | nil
        }

  @doc """
  Force a full rebuild of the full-text search index.

  Running this will delete the entire existing index, rebuilding it
  based on the content of the external content view, `unified_search_view`.

  NOTE: This is necessary for initial generation of the full-text search
  index after changes to any subqueries of the view, as well as addition
  or removal of columns or any other redefinition of the FTS virtual table.

  While the application is small---containing fewer than a million
  records---and while the rebuild command is adequately fast so as not to
  place an unbearable burden upon the database or rebuild time---fewer
  than ten seconds, for example---then this is the preferred way to
  keep the index up to date.

  Once these assumptions no longer hold, then the populating of the
  table will need to be carried out by way of incremental `INSERT INTO`
  queries, best run by defined `TRIGGER`s.
  """
  @spec rebuild_fts_index() ::
          {:ok, exqlite_result()} | any()
  def rebuild_fts_index do
    Repo.transaction(fn ->
      Ecto.Adapters.SQL.query!(
        Repo,
        "INSERT INTO search(search) VALUES ('rebuild');",
        []
      )
    end)
  end

  @doc false
  @spec from_search_fts() :: Ecto.Query.t()
  def from_search_fts() do
    from(s in UnifiedSearch, as: :search)
  end

  @doc false
  @spec filter_search_fts_matching_fts(query :: Ecto.Query.t(), search_phrase :: String.t()) ::
          Ecto.Query.t()
  def filter_search_fts_matching_fts(query, search_phrase) do
    from [search: ns] in query,
      where: fragment("search MATCH ?", ^search_phrase)
  end

  @doc false
  @spec order_by_search_fts_asc_rank(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def order_by_search_fts_asc_rank(query) do
    from [search: ns] in query,
      order_by: [asc: :rank]
  end

  @doc false
  @spec select_search_fts_all_fields(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_search_fts_all_fields(query) do
    from [search: s] in query,
      select: %{
        id: s.entity_id,
        entity: s.entity,
        category: s.category,
        status: s.status,
        title: s.title,
        subtitle: s.subtitle,
        author: s.author,
        tags: s.tags,
        location: s.location,
        text: s.text,
        result:
          fragment(
            "snippet(search, -1, \'<span class=\"font-semibold group-hover:font-bold underline decoration-peach-fuzz-600 group-hover:decoration-peach-fuzz-50 text-peach-fuzz-600 group-hover:text-peach-fuzz-50\">\', \'</span>\', \'…\', 64)"
          )
      }
  end

  @doc false
  @spec select_search_fts_options_for_select(query :: Ecto.Query.t()) :: Ecto.Query.t()
  def select_search_fts_options_for_select(query) do
    from [search: s] in query,
      select: %{
        value: s.entity_id,
        label: s.title,
        subtitle: s.subtitle,
        result:
          fragment(
            "snippet(search, -1, \'<span class=\"font-semibold group-hover:font-bold underline decoration-peach-fuzz-600 group-hover:decoration-peach-fuzz-50 text-peach-fuzz-600 group-hover:text-peach-fuzz-50\">\', \'</span>\', \'…\', 64)"
          )
      }
  end

  @doc """
  Search all entities using full-text search.

  ## Examples

      iex> search("hello")
      [%Klepsidra.Search.UnifiedSearch{}, ...]

  """
  @spec search_and_highlight_snippet(search_phrase :: String.t()) ::
          [%{id: Ecto.UUID.t(), result: String.t()}, ...]
  def search_and_highlight_snippet(search_phrase) do
    from_search_fts()
    |> filter_search_fts_matching_fts(search_phrase)
    |> order_by_search_fts_asc_rank()
    |> select_search_fts_all_fields()
    |> Repo.all()
  end

  @doc false
  @spec search_and_highlight_snippet_options_for_select(search_phrase :: String.t()) ::
          [%{id: Ecto.UUID.t(), result: String.t()}, ...]
  def search_and_highlight_snippet_options_for_select(search_phrase) do
    from_search_fts()
    |> filter_search_fts_matching_fts(search_phrase)
    |> order_by_search_fts_asc_rank()
    |> select_search_fts_options_for_select()
    |> Repo.all()
  end
end
