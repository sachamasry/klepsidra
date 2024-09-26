defmodule Klepsidra.Repo.Migrations.CreateJournalEntries do
  use Ecto.Migration

  def change do
    create table(:journal_entries,
             primary_key: false,
             comment:
               "Journal entries are entities where users can log their mood, feelings, lessons learned that day, etc."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based journal entry primary key"

      add :journal_for, :string,
        comment: "What period is this entry for? This is an ISO 8601 date stamp"

      add :entry_text_markdown, :text,
        comment: "The journal entry, in Markdown or plain text format"

      add :entry_text_html, :text,
        null: false,
        comment: "The journal entry, formatted in ready to render HTML"

      add :highlights, :text,
        default: false,
        comment: "Summary of key takeaways or highlights from the entry"

      add :entry_type_id, references(:journal_entry_types, on_delete: :nothing, type: :uuid),
        null: false

      add :location, :string,
        default: false,
        comment: "Where was the user when they recorded the entry?"

      add :latitude, :float, comment: "User's GPS latitude at time of entry"

      add :longitude, :float, comment: "User's GPS longitude at time of entry"

      add :mood, :string, comment: "Describe your mood here, if relevant"

      add :is_private, :boolean,
        default: false,
        null: false,
        comment:
          "Is this journal entry private and confidential, to be treated with higher level of privacy than regular entries?"

      add :is_short_entry, :boolean,
        default: false,
        null: false,
        comment:
          "Flag indicating whether this is a short, one-line entry, or a longer more detailed one"

      add :is_scheduled, :boolean,
        default: false,
        null: false,
        comment: "Track whether this entry is linked to a scheduled journal"

      add :user_id, references(:users, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:journal_entries, [:journal_for],
             comment:
               "Index of `journal_for` field, for easier sorting and searching for entries, for the period that they are made for"
           )

    create index(:journal_entries, [:user_id],
             comment:
               "Secondary index of the journal entry's `user_id` field, signifying the user the entry belongs to"
           )

    create index(:journal_entries, [:entry_type_id],
             comment:
               "Secondary index of the journal entry's `entry_type_id`, flagging the journal entry as being of a particular type"
           )

    create index(:journal_entries, [:is_private],
             comment:
               "Index on the `is_private` flag, allowing easy sorting and filtering on the field"
           )

    create index(:journal_entries, [:inserted_at],
             comment:
               "Index on the `inserted_at` field, allowing easy sorting and filtering by the date the entry was actually recorded"
           )
  end
end
