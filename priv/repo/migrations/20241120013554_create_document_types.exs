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
        comment:
          "Human-readable document type, e.g. 'passport', 'visa', 'driving license', 'ID card', etc."

      add :description, :text, comment: "Any other document type details which may be useful."

      add :max_validity_period_unit, :string,
        null: true,
        default: "years",
        comment: "Maximum validity time unit for this type of document (e.g. 'years')"

      add :max_validity_duration, :integer,
        null: true,
        default: 0,
        comment:
          "Maximum validity duration for this type of documents in time units specified (e.g. 10)"

      add :is_country_specific, :boolean,
        null: false,
        default: true,
        comment: "Indicates if this document type varies by country"

      add :requires_renewal, :boolean,
        null: false,
        default: true,
        comment: "Indicates if renewal is required for this type of document"

      timestamps()
    end

    create unique_index(:document_types, [:name],
             unique: true,
             comment: "Unique index on document type"
           )

    create index(:document_types, :is_country_specific,
             comment: "Index `is_country_specific` field for faster searching and filtering"
           )

    create index(:document_types, :requires_renewal,
             comment: "Index `requires_renewal` field for faster searching and filtering"
           )

    create index(
             :document_types,
             [
               :max_validity_period_unit,
               :max_validity_duration
             ],
             comment:
               "Composite index optimising queries that filter on a combination of default validity time unit and duration fields, avoiding full-table scans"
           )
  end
end
