defmodule Klepsidra.Repo.Migrations.CreateUserDocuments do
  use Ecto.Migration

  def change do
    create table(:user_documents,
             primary_key: false,
             comment:
               "User documents are usually government or other legally binding documents belonging to a user, with issue and expiry dates to track, and pending renewals to notify about."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based journal entry primary key"

      add :document_type_id, references(:document_types, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "Type of document. Foreign key to `document_types` table"

      add :user_id, references(:users, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "User reference. Foreign key to `users` table"

      add :country_id,
          references(:locations_countries,
            column: :iso_3_country_code,
            on_delete: :nothing,
            type: :string
          ),
          null: true,
          comment: "Foreign key to `locations_countries` table, ISO-3 country code"

      add :document_issuer_id, references(:document_issuers, on_delete: :nothing, type: :uuid),
        null: true,
        comment: "Document issuing authority. Foreign key to `document_issuers` table"

      add :unique_reference_number, :string,
        null: false,
        comment:
          "Unique document reference given by the document issuing body, i.e. passport number, national ID, driving license number, etc."

      add :name, :string,
        null: true,
        comment: "User-defined title or name for the document"

      add :description, :string, comment: "Additional details or context"

      add :issued_at, :date,
        null: true,
        comment: "Date when the document was issued"

      add :expires_at, :date,
        null: true,
        comment: "Expiry date of the document"

      add :is_active, :boolean,
        default: true,
        null: false,
        comment: "Indicates if the document is currently valid"

      add :invalidation_reason, :string,
        null: true,
        comment:
          "If this document has been made inactive before its expiry time, explanation for why the document is no longer valid"

      add :file_url, :string, comment: "URL or path reference to document"

      add :custom_buffer_time_days, :integer,
        null: true,
        default: nil,
        comment:
          "User-defined override for notification lead time (in days), a buffer time for user action for this particular document"

      timestamps()
    end

    create unique_index(:user_documents, [:unique_reference_number],
             comment: "Unique index on the document's `unique_reference_number` field"
           )

    create index(:user_documents, [:document_type_id],
             comment:
               "Index of the user document's `document_type_id` field, classifying the document type, optimising searches for documents by type"
           )

    create index(:user_documents, [:user_id],
             comment:
               "Index of the user document's `user_id` field, optimising searches filtering or joining by user, such as retrieving all documents for a specific user"
           )

    create index(:user_documents, [:user_id, :document_type_id],
             comment:
               "Composite index of the user document's `user_id` and `document_type_id` fields, optimising queries where users search for documents by type"
           )

    create index(:user_documents, [:expires_at],
             comment:
               "Index of the user document's `expires_at` date field, facilitating queries for finding documents that are about to expire. Critical for generating expiration reminders and notifications"
           )

    create index(:user_documents, [:country_id],
             comment:
               "Index of the user document's `country_id` field, useful for queries that filter documents by the issuing country"
           )

    create index(:user_documents, [:document_type_id, :country_id],
             comment:
               "Composite index of the user document's `document_type_id` and `country_id` fields, optimising queries for filtering by document type and country, such as when finding templates or issuing rules for a particular type in a specific country"
           )
  end
end
