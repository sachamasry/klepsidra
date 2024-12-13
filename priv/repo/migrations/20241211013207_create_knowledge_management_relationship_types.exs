defmodule Klepsidra.Repo.Migrations.CreateKnowledgeManagementRelationshipTypes do
  use Ecto.Migration

  def change do
    create table(:knowledge_management_relationship_types,
             primary_key: false,
             comment:
               "Knoledge Management relationship types table, categorising note relationships"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based relationship type primary key"

      add :name, :string,
        null: false,
        comment:
          "The relationship type; must be unique and meaningful. Named to reflect its outbound nature, i.e. 'note A' -- relates to --> 'note B' with relationship type"

      add :reverse_name, :string,
        null: false,
        comment:
          "The relationship type; must be unique and meaningful. Named to reflect its reverse relationship - inbound - nature, i.e. 'note A' <-- is related from -- 'note B' with relationship type"

      add :description, :text,
        comment: "Brief description of relationship type and its use in knowledge management"

      add :default, :boolean,
        default: false,
        comment: "Set this as a default, generic relationship type"

      add :is_predefined, :boolean,
        default: false,
        null: false,
        comment: "Is this relationship type part of a tight list of provided definitions?"

      timestamps()
    end

    create unique_index(:knowledge_management_relationship_types, :name,
             comment:
               "Unique index of the relationship type `name` field, optimising searches filtering and ordering notes by their title"
           )

    create index(:knowledge_management_relationship_types, :reverse_name,
             comment:
               "Index of the relationship type `reverse_name` field, optimising searches filtering and ordering notes by their inverse title"
           )

    create index(:knowledge_management_relationship_types, :default,
             comment: "Index on default flag of relationship types"
           )

    create index(:knowledge_management_relationship_types, :is_predefined,
             comment: "Index on status of predefined definitions"
           )
  end
end
