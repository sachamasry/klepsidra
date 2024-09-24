defmodule Klepsidra.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories,
             primary_key: false,
             comment:
               "The categories table helps categorise types of journal entry, e.g. mood, gratitude, inspiration, learning log, etc."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based journal category primary key"

      add :name, :string,
        null: false,
        comment: "Unique journal category name"

      add :description, :text,
        comment: "Any other information about the category which may be useful in the future"

      timestamps()
    end

    create unique_index(:categories, [:name],
             unique: true,
             comment: "Unique index on the category name"
           )
  end
end
