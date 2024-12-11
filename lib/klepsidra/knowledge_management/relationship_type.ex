defmodule Klepsidra.KnowledgeManagement.RelationshipType do
  @moduledoc """
  Defines the `RelationshipType` schema needed to categorise relationships
  between notes.

  Every relationship between two notes must have exactly one
  relationship type.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t(),
          is_predefined: boolean()
        }
  schema "knowledge_management_relationship_types" do
    field :name, :string
    field :description, :string
    field :is_predefined, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(relationship_type, attrs) do
    relationship_type
    |> cast(attrs, [:name, :description, :is_predefined])
    |> validate_required([:name], message: "Enter the relationship type")
    |> validate_required([:is_predefined])
  end
end
