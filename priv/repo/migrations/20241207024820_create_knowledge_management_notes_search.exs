defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNotesSearch do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_management_notes_search
    USING fts5(id UNINDEXED, title, content, summary, tokenize='trigram remove_diacritics 1');
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ai AFTER INSERT
    ON knowledge_management_notes
    BEGIN
      INSERT INTO knowledge_management_notes_search(rowid, id, title, content, summary)
      VALUES (NEW.rowid, NEW.id, NEW.title, NEW.content, NEW.summary);
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ad AFTER DELETE
    ON knowledge_management_notes
    BEGIN
      DELETE FROM knowledge_management_notes_search WHERE rowid = OLD.rowid;
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_au AFTER UPDATE
    ON knowledge_management_notes
    BEGIN
      UPDATE knowledge_management_notes_search
      SET title = NEW.title, content = NEW.content, summary = NEW.summary
      WHERE rowid = NEW.rowid;
    END;
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_ai;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_ad;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_au;")
    execute("DROP TABLE IF EXISTS knowledge_management_notes_search;")
  end
end
