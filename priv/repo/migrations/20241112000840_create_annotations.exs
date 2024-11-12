defmodule Klepsidra.Repo.Migrations.CreateAnnotations do
  use Ecto.Migration

  def change do
    create table(:annotations,
             primary_key: false,
             comment:
               "Annotations are entities containing annotations of source material or quotes from same."
           ) do
      add(:id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based annotation primary key"
      )

      add(:entry_type, :string,
        null: false,
        comment: "Differentiate between 'annotation' and 'quote' types"
      )

      add(:text, :string,
        null: false,
        comment: "Text of the source annotation or quote"
      )

      add(:author_name, :string, comment: "Author name string")
      add(:comment, :string, comment: "Annotator's comment on the annotation or quote")

      add(:position_reference, :string,
        comment:
          "Reference to the location in the source material where the annotation or quote is found"
      )

      timestamps()
    end

    create(
      index(:annotations, :entry_type,
        comment: "Index on the `entry_type` field, supporting fast look-ups"
      )
    )
  end
end
