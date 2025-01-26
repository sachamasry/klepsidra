defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNotesSearch do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIRTUAL TABLE IF NOT EXISTS search
    USING fts5(entity_id UNINDEXED, entity, category, status, owner_id, group_id, title, subtitle, author, tags, location, text, inserted_at, updated_at, content='unified_search_view', tokenize='trigram remove_diacritics 1');
    """)
  end

  def down do
    execute("DROP TABLE IF EXISTS search;")
  end
end
