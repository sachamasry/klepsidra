defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNotesSearch do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_management_notes_search
    USING fts5(id UNINDEXED, title, content, summary, tags,
      tokenize='trigram remove_diacritics 1');
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ai
    AFTER INSERT ON knowledge_management_notes
    BEGIN
      INSERT INTO knowledge_management_notes_search(rowid, id, title, content,
        summary, tags)
      SELECT NEW.rowid, kmn.id, kmn.title, kmn.content, kmn.summary, GROUP_CONCAT(t.name, ', ') tags
      FROM knowledge_management_notes kmn
      LEFT JOIN knowledge_management_note_tags kmnt
      ON kmn.id = kmnt.note_id
      LEFT JOIN tags t
      ON kmnt.tag_id = t.id
      WHERE kmn.id = NEW.id
      GROUP BY kmn.id, kmn.title, kmn.content, kmn.summary;
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_note_search_note_tags_ai
    AFTER INSERT ON knowledge_management_note_tags
    BEGIN
      INSERT INTO knowledge_management_notes_search(rowid, id, title, content,
        summary, tags)
      SELECT NEW.rowid, kmn.id, kmn.title, kmn.content, kmn.summary, GROUP_CONCAT(t.name, ', ') tags
      FROM knowledge_management_notes kmn
      LEFT JOIN knowledge_management_note_tags kmnt
      ON kmn.id = kmnt.note_id
      LEFT JOIN tags t
      ON kmnt.tag_id = t.id
      WHERE kmn.id = NEW.note_id
      GROUP BY kmn.id, kmn.title, kmn.content, kmn.summary;
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ad
    AFTER DELETE ON knowledge_management_notes
    BEGIN
      DELETE FROM knowledge_management_notes_search WHERE rowid = OLD.rowid;
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_au
    AFTER UPDATE ON knowledge_management_notes
    BEGIN
      DELETE FROM knowledge_management_notes_search WHERE id = OLD.id;

      INSERT INTO knowledge_management_notes_search(rowid, id, title, content,
        summary, tags)
      SELECT NEW.rowid, kmn.id, kmn.title, kmn.content, kmn.summary, GROUP_CONCAT(t.name, ', ') tags
      FROM knowledge_management_notes kmn
      LEFT JOIN knowledge_management_note_tags kmnt
      ON kmn.id = kmnt.note_id
      LEFT JOIN tags t
      ON kmnt.tag_id = t.id
      WHERE kmn.id = NEW.id
      GROUP BY kmn.id, kmn.title, kmn.content, kmn.summary;
    END;
    """)

    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_note_tags_ad
    AFTER DELETE ON knowledge_management_note_tags
    BEGIN
      DELETE FROM knowledge_management_notes_search WHERE id = OLD.note_id;

      INSERT INTO knowledge_management_notes_search(rowid, id, title, content,
        summary, tags)
      SELECT OLD.rowid, kmn.id, kmn.title, kmn.content, kmn.summary, GROUP_CONCAT(t.name, ', ') tags
      FROM knowledge_management_notes kmn
      LEFT JOIN knowledge_management_note_tags kmnt
      ON kmn.id = kmnt.note_id
      LEFT JOIN tags t
      ON kmnt.tag_id = t.id
      WHERE kmn.id = OLD.note_id
      GROUP BY kmn.id, kmn.title, kmn.content, kmn.summary;
    END;
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_ai;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_note_search_note_tags_ai;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_ad;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_note_tags_ad;")
    execute("DROP TRIGGER IF EXISTS knowledge_management_notes_search_au;")
    execute("DROP TABLE IF EXISTS knowledge_management_notes_search;")
  end
end
