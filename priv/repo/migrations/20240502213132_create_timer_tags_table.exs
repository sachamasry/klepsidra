defmodule Klepsidra.Repo.Migrations.CreateTimerTags do
  use Ecto.Migration

  def change do
    create table(:timer_tags,
             primary_key: false,
             comment:
               "Activity timer tags table, helping categorise timers with tags in a many-to-many relationship"
           ) do
      add(
        :timer_id,
        references(:timers, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing activity timers"
      )

      add(:tag_id, references(:tags, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing tags"
      )

      timestamps()
    end

    create(
      unique_index(:timer_tags, [:timer_id, :tag_id],
        comment: "Composite unique index of `timer_id` and `tag_id` fields"
      )
    )
  end
end
