defmodule Klepsidra.Repo.Migrations.CreateBusinessPartners do
  use Ecto.Migration

  def change do
    create table(:business_partners,
             comment:
               "Business partners are any entity the organisation has financial dealings with, such as customers and suppliers, but also internal staff"
           ) do
      add :name, :string,
        commment:
          "Legal business partner's name, for use on invoices, timesheets and other legal documents"

      add :description, :text,
        comment: "Any other business partner details, which may be useful in the future"

      add :default_currency, :string,
        comment: "What currency does the business partner transact in?"

      add :customer, :boolean,
        default: false,
        null: false,
        comment: "Is this business partner a customer?"

      add :supplier, :boolean,
        default: false,
        null: false,
        comment: "Is this business partner a supplier?"

      add :frozen, :boolean,
        default: false,
        null: false,
        comment:
          "Is this partner 'frozen' out of further financial transactions, e.g. due to outstanding credit, etc?"

      add :active, :boolean,
        default: true,
        null: false,
        comment:
          "Is thiis business partner still active and current with the organisation? Legacy business partners can be made inactive, and will not show on lists and select controls"

      timestamps()
    end

    create unique_index(:business_partners, [:name])
  end
end
