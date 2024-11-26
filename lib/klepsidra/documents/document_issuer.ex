defmodule Klepsidra.Documents.DocumentIssuer do
  @moduledoc """
  Defines the `DocumentIssuer` schema and functions needed to manage document
  issuer entities.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.Locations.Country

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t(),
          country_id: String.t(),
          contact_information: map(),
          website_url: String.t()
        }
  schema "document_issuers" do
    field :name, :string
    field :description, :string

    belongs_to(:locations_countries, Country,
      foreign_key: :country_id,
      references: :iso_3_country_code,
      type: :string
    )

    field :contact_information, :map
    field :website_url, :string

    timestamps()
  end

  @doc false
  def changeset(document_issuer, attrs) do
    document_issuer
    |> cast(attrs, [:name, :description, :country_id, :contact_information, :website_url])
    |> validate_required([:name], message: "Enter the document issuer name")
    |> unique_constraint(:name, message: "There is already a document issuer with that name")
  end
end
