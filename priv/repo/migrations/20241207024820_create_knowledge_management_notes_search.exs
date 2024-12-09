defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNotesSearch do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_management_notes_search
    USING fts5(note_id UNINDEXED, title, content, summary, tags,
      tokenize='trigram remove_diacritics 1');
    """)

    # When a new note is created, it will not have had any tags attached
    # just yet; insert an empty string into the tag field
    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ai
    AFTER INSERT ON knowledge_management_notes
    BEGIN
      INSERT INTO knowledge_management_notes_search(rowid, note_id, title, content,
        summary, tags)
      VALUES (NEW.rowid, NEW.id, NEW.title, NEW.content, NEW.summary, '');
    END;
    """)

    # A tag can only be attached to the knowledge_management_note_tags table
    # after a note record has been created, so all that's needed is to find
    # the correct note record in the search table, updating its 'tags' field
    # value to the concatenation of all the tags assigned to the note
    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_note_search_note_tags_ai
    AFTER INSERT ON knowledge_management_note_tags
    BEGIN
      UPDATE knowledge_management_notes_search
      SET tags = (
        SELECT GROUP_CONCAT(t.name, ' ⸱ ') tags
        FROM knowledge_management_note_tags kmnt
        LEFT JOIN tags t
        ON kmnt.tag_id = t.id
        WHERE kmnt.note_id = NEW.note_id
      )
      WHERE note_id = NEW.note_id;
    END;
    """)

    # When an actual note is deleted, remove it completely from the search
    # index
    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_ad
    AFTER DELETE ON knowledge_management_notes
    BEGIN
      DELETE FROM knowledge_management_notes_search WHERE rowid = OLD.rowid;
    END;
    """)

    # When a note is updated, update its title, content and summary fields
    # only
    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_au
    AFTER UPDATE ON knowledge_management_notes
    BEGIN
      UPDATE knowledge_management_notes_search
      SET title = NEW.title, content = NEW.content, summary = NEW.summary
      WHERE rowid = NEW.rowid;
    END;
    """)

    # When a tag is deleted, all that needs to be done is to rebuild the note's
    # tag concatenation string, which will now be shorter by one item, and UPDATE
    # the 'tags' field in the correct row in the search table
    execute("""
    CREATE TRIGGER IF NOT EXISTS knowledge_management_notes_search_note_tags_ad
    AFTER DELETE ON knowledge_management_note_tags
    BEGIN
      UPDATE knowledge_management_notes_search
      SET tags = (
        SELECT GROUP_CONCAT(t.name, ' ⸱ ') tags
        FROM knowledge_management_note_tags kmnt
        LEFT JOIN tags t
        ON kmnt.tag_id = t.id
        WHERE kmnt.note_id = NEW.note_id
      )
      WHERE note_id = OLD.note_id;
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
