defmodule Klepsidra.Repo.Migrations.CreateBusinessPartners do
  use Ecto.Migration

  def change do
    create table(:business_partners,
             primary_key: false,
             comment:
               "Business partners are any entity the organisation has financial dealings with, such as customers and suppliers, but also internal staff"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based business partner primary key"

      add :name, :string,
        null: false,
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
          "Is this business partner still active and current with the organisation? Legacy business partners can be made inactive, and will not show on lists and select controls"

      timestamps()
    end

    create unique_index(:business_partners, [:name],
             unique: true,
             comment: "Unique index on business partner names"
           )

    create index(:business_partners, [:customer],
             comment: "Index of business partner `customer` flag field"
           )

    create index(:business_partners, [:supplier],
             comment: "Index of business partner `supplier` flag field"
           )

    create index(:business_partners, [:frozen],
             comment: "Index of business partner `frozen` flag field"
           )

    create index(:business_partners, [:active],
             comment: "Index of business partner `active` flag field"
           )
  end
end
