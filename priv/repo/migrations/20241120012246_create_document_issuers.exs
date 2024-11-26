defmodule Klepsidra.Repo.Migrations.CreateDocumentIssuers do
  use Ecto.Migration

  def change do
    create table(:document_issuers,
             primary_key: false,
             comment:
               "Document issuers provides a list of public and governmental authorities, as well as private bodies (such as banks, financial institutions, educational bodies, etc.), authorised to issue documents."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based document issuer primary key"

      add :name, :string,
        null: false,
        comment: "Name of authorised document issuer"

      add :description, :text, comment: "Any other document issuer details which may be useful."

      add :country_id,
          references(:locations_countries,
            column: :iso_3_country_code,
            on_delete: :nothing,
            type: :string
          ),
          null: true,
          comment: "Foreign key to locations_countries table, ISO-3 country code"

      add :contact_information, :map,
        null: false,
        default: %{},
        comment:
          "Contact_information for the document issuer. Defined as JSONB because it allows flexibility and efficiency in storing complex, semi-structured data that varies across issuers"

      add :website_url, :text,
        null: true,
        comment: "Document issuer's URL on the internet"

      timestamps()
    end

    create unique_index(:document_issuers, [:name],
             comment: "Unique index on the document issuer name field"
           )

    create index(:document_issuers, [:country_id],
             comment:
               "Index on the document issuer country_id field, helping optimise issuer search and filtering operations by their country"
           )
  end
end
