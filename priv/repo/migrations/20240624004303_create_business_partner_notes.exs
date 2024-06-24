defmodule Klepsidra.Repo.Migrations.CreateBusinessPartnerNotes do
  use Ecto.Migration

  def change do
    create table(:business_partner_notes) do
      add :note, :string
      add :user_id, :integer
      add :business_partner_id, references(:business_partners, on_delete: :nothing)

      timestamps()
    end

    create index(:business_partner_notes, [:business_partner_id])
  end
end
