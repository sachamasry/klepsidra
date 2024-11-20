defmodule Klepsidra.Repo.Migrations.CreateUserDocuments do
  use Ecto.Migration

  def change do
    create table(:user_documents,
             primary_key: false,
             comment:
               "User documents are usually government or other legally binding documents with issue and expiry dates to track."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based journal entry primary key"

      add :document_type_id, references(:document_types, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "Foreign key to `document_types` table"

      add :user_id, references(:users, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "Foreign key to `users` table"

      add :unique_reference, :string,
        null: false,
        comment: "Unique document reference given by the issuing body"

      add :issued_by, :string,
        null: false,
        comment: "Name of the body issuing the document"

      add :issuing_country_id,
          references(:locations_countries, on_delete: :nothing, type: :string),
          null: false,
          comment:
            "Foreign key to the `locations_countries` table, identifying the document-issuing country"

      add :issue_date, :date,
        null: false,
        comment: "Date the document was issued and is valid from"

      add :expiry_date, :date,
        null: false,
        comment: "Date the document expires and is invalid from"

      add :is_active, :boolean,
        default: true,
        null: false,
        comment: "Is this document currently active?"

      add :is_active_comment, :string,
        comment:
          "If this document has been made inactive before its expiry time, record why and how the change in status came about"

      add :file_url, :string, comment: "URL or path reference to document"

      timestamps()
    end

    create index(:user_documents, [:document_type_id],
             comment:
               "Secondary index of the user document's `document_type_id` field, classifying the document type"
           )

    create index(:user_documents, [:user_id],
             comment:
               "Secondary index of the user document's `user_id` field, signifying the user the entry belongs to"
           )
  end
end
