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
          description: String.t()
        }
  schema "document_types" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(document_type, attrs) do
    document_type
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name,
      message: "A document type with this name already exists"
    )
  end
end
