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

      add :notification_lead_time, :integer,
        null: false,
        default: 30,
        comment: "Number of days before expiry to raise a notification for this type of document"

      add :processing_time_estimate, :integer,
        null: false,
        default: 30,
        comment: "Estimated number of days for document issuance"

      add :default_user_buffer_time, :integer,
        null: false,
        default: 7,
        comment: "Default number of buffer days, allowing the user to act on notification"

      timestamps()
    end

    create unique_index(:document_types, [:name],
             unique: true,
             comment: "Unique index on document type"
           )
  end
end
