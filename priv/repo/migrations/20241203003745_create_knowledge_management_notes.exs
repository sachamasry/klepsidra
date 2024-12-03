defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementNotes do
  use Ecto.Migration

  def change do
    create table(:knowledge_management_notes,
             primary_key: false,
             comment:
               "Record of standalone and versatile notes of broader thematic potential, such as (but not limited to) thoughts, research insights, concepts, reflections, synthesis or summaries not necessarily linked to a particular citation or source. Notes are primary units of thought and knowledge, which can interlink, forming a knowledge base."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based notes primary key"

      add :title, :string,
        null: false,
        comment: "The title of the note; must be unique and meaningful"

      add :content, :text,
        null: false,
        comment: "Main content/body of the note"

      add :content_format, :string,
        null: false,
        default: "plaintext",
        comment: "Format of content, e.g. 'markdown', 'org-mode', 'plaintext', 'html'"

      add :rendered_content, :text, comment: "Rendered output"

      add :rendered_content_format, :string,
        default: "html",
        comment: "Format of rendered content, e.g. 'html', 'pdf', 'plaintext', 'other'"

      add :summary, :text,
        null: true,
        comment: "A brief summary or abstract of the note"

      add :status, :string,
        null: false,
        default: "fleeting",
        comment: "Lifecycle state, e.g. 'draft', 'fleeting', 'evergreen', 'archived'"

      add :review_date, :date,
        null: true,
        default: nil,
        comment: "Next scheduled review date"

      add :pinned, :boolean,
        default: false,
        null: false,
        comment: "Indicates whether the note is pinned"

      add :attachments, :map,
        null: true,
        default: nil,
        comment:
          "A JSON field to store metadata about attached files, embedded media, or links. This can include filenames, URLs, or base64-encoded data"

      add :priority, :integer,
        null: true,
        default: nil,
        comment: "Importance/urgency of the note"

      timestamps()
    end

    create index(:knowledge_management_notes, [:title],
             comment:
               "Index of the note's `title` field, optimising searches filtering and ordering notes by their title"
           )

    create index(:knowledge_management_notes, [:status],
             comment:
               "Index of the note's `status` field, optimising searches filtering notes by their status"
           )

    create index(:knowledge_management_notes, [:pinned],
             comment:
               "Index of the note's `pinned` field, optimising searches filtering or prioritising pinned notes"
           )

    create index(:knowledge_management_notes, [:priority],
             comment:
               "Index of the note's `priority` field, optimising searches filtering or prioritising notes"
           )

    create index(:knowledge_management_notes, [:status, :pinned, :priority],
             comment:
               "Composite index of the note's `status`, `pinned` and `priority` fields, optimising queries relying on multiple criteria, avoiding the need for a full scan of the table"
           )

    create index(:knowledge_management_notes, [:review_date],
             comment:
               "Index of the note's `review_date` field, optimising searches for notes due for review"
           )

    create index(:knowledge_management_notes, [:content_format],
             comment:
               "Index of the note's `content_format` field, optimising note querying by their input format"
           )

    create index(:knowledge_management_notes, [:rendered_content_format],
             comment:
               "Index of the note's `rendered_content_format` field, optimising note querying by their rendered output format"
           )

    create index(:knowledge_management_notes, [:status, :updated_at],
             comment:
               "Composite index of the note's `status` and `updated_at` fields, optimising queries relying on multiple criteria"
           )
  end
end
