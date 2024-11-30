defmodule Klepsidra.Documents.DocumentType do
  @moduledoc """
  Defines the `DocumentTypes` schema and functions needed to classify 
  documents by type.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t(),
          max_validity_period_unit: String.t(),
          max_validity_duration: integer(),
          is_country_specific: boolean(),
          requires_renewal: boolean()
        }
  schema "document_types" do
    field :name, :string
    field :description, :string
    field :max_validity_period_unit, :string
    field :max_validity_duration, :integer
    field :is_country_specific, :boolean, default: true
    field :requires_renewal, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(document_type, attrs) do
    document_type
    |> cast(attrs, [
      :name,
      :description,
      :max_validity_period_unit,
      :max_validity_duration,
      :is_country_specific,
      :requires_renewal
    ])
    |> validate_required([:name], message: "Enter a document type name")
    |> validate_required([
      :is_country_specific,
      :requires_renewal
    ])
    |> unique_constraint(:name,
      message: "A document type with this name already exists"
    )
  end
end
