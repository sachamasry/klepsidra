defmodule Klepsidra.Repo.Migrations.CreateDocumentTypes do
  use Ecto.Migration

  def change do
    create table(:document_types,
             primary_key: false,
             comment:
               "Document types improves the application by normalising document type classification to an external table."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based document types primary key"

      add :name, :string,
        null: false,
        comment: "Human-readable document type, e.g. 'passport', 'visa', 'driving license', etc."

      add :description, :text,
        comment: "Any other document type details which may be useful in the future."

      timestamps()
    end

    create unique_index(:document_types, [:name],
             unique: true,
             comment: "Unique index on document type"
           )
  end
end
