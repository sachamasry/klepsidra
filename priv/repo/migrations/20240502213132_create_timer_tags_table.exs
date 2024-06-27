defmodule Klepsidra.Repo.Migrations.CreateTimerTags do
  use Ecto.Migration

  def change do
    create table(:timer_tags,
             primary_key: false,
             comment:
               "Activity timer tags table, helping categorise timers with tags in a many-to-many relationship"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based timer tags primary key"

      add :tag_id, references(:tags, on_delete: :delete_all, on_replace: :delete, type: :uuid),
        comment: "Foreign key referencing tags"

      add :timer_id, references(:timers, on_delete: :delete_all, on_replace: :delete),
        comment: "Foreign key referencing activity timers"

      timestamps()
    end

    create index(:timer_tags, [:tag_id], comment: "Index with the `tag_id` as an indexed key")

    create index(:timer_tags, [:timer_id],
             comment: "Index with the activity timer `timer_id` as an indexed key"
           )

    create unique_index(:timer_tags, [:tag_id, :timer_id],
             comment:
               "Index with the activity timer `timer_id` and `tag_id` as a composite indexed key"
           )
  end
end
