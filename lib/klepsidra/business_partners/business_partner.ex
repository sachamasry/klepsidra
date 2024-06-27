defmodule Klepsidra.BusinessPartners.BusinessPartner do
  @moduledoc """
  Defines a schema for the `Business Partners` entity, recording customers and
  suppliers of the busines.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          customer: boolean(),
          supplier: boolean(),
          active: boolean()
        }
  schema "business_partners" do
    field :name, :string
    field :description, :string
    field :customer, :boolean, default: false
    field :supplier, :boolean, default: false
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(business_partner, attrs) do
    business_partner
    |> cast(attrs, [:name, :description, :customer, :supplier, :active])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :business_partners_name_index)
  end

  @doc """
  Used across live components to populate select options with projects.
  """
  @spec populate_customers_list() :: [Klepsidra.BusinessPartners.BusinessPartner.t(), ...]
  def populate_customers_list() do
    [
      {"-- Select Customer --", ""}
      | Klepsidra.BusinessPartners.list_business_partners()
        |> Enum.map(fn bp -> {bp.name, bp.id} end)
    ]
  end
end
