defmodule Klepsidra.Repo.Migrations.CreateBusinessPartnerNotes do
  use Ecto.Migration

  def change do
    create table(:business_partner_notes,
             primary_key: false,
             comment: "Table to store business partner annotations and running comments"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based business partner notes primary key"

      add :note, :text, comment: "Note or commentary on the business partner"

      add :business_partner_id, references(:business_partners, on_delete: :nothing, type: :uuid),
        comment: "Foreign key referencing the business partner"

      timestamps()
    end

    create index(:business_partner_notes, [:business_partner_id],
             comment: "Index with the `business_partner_id` as the main indexed key"
           )

    create index(:business_partner_notes, [:inserted_at, :updated_at],
             comment:
               "Composite Index of `inserted_at` and `updated_at` fields, for chronological ordering"
           )
  end
end
