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

      add :default_validity_period_unit, :string,
        null: false,
        default: "years",
        comment: "Default validity time unit for this type (e.g. 'years')"

      add :default_validity_duration, :integer,
        null: false,
        default: 0,
        comment: "Default validity duration for this type, in time units specified (e.g. 10)"

      add :notification_lead_time_days, :integer,
        null: false,
        default: 30,
        comment:
          "Recommended days before expiry to trigger renewal notification for this type of document"

      add :processing_time_estimate_days, :integer,
        null: false,
        default: 30,
        comment: "Estimated document issuance processing and delivery time, in days"

      add :default_buffer_time_days, :integer,
        null: false,
        default: 14,
        comment: "Default safety buffer, in days, for user action"

      add :is_country_specific, :boolean,
        null: false,
        default: false,
        comment: "Indicates if this document type varies by country"

      add :requires_renewal, :boolean,
        null: false,
        default: true,
        comment: "Indicates if renewal is required"

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
               :default_validity_period_unit,
               :default_validity_duration,
               :notification_lead_time_days,
               :processing_time_estimate_days,
               :default_buffer_time_days
             ],
             comment:
               "Composite index optimising queries that filter on a combination of default validity, `notification_lead_time_days`, `processing_time_estimate_days`, `default_buffer_time_days` fields, avoiding full-table scans"
           )
  end
end
