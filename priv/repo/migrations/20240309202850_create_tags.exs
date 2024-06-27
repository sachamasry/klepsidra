defmodule Klepsidra.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags,
             primary_key: false,
             comment:
               "Freeform tags table, helping categorise timed activities, projects and other entities. Useful in searching for and filtering projects and activities in lists, and in future data mining and analysis"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based tags primary key"

      add :name, :string,
        null: false,
        comment:
          "Human readable tag name, e.g. 'research', 'learning', 'testing', 'exercise', etc. For faceted search and filtering, and future reporting, colon-delimited namespacing can be used, i.e. 'development:web applications"

      add :colour, :string,
        comment:
          "Tags may have colours applied to them, helping to quickly visually distinguish amongst different categories"

      add :fg_colour, :string,
        comment:
          "Some background colours which can be defined in the `colour` field may become illegible, owing to poor contrast. Define an appropriate text foreground colour in this field"

      add :description, :text,
        comment: "Human readable description of the intended purpose and use of this tag"

      timestamps()
    end

    create unique_index(:tags, [:name], comment: "Index with the name as the main indexed key")
  end
end
