defmodule Klepsidra.BusinessPartners.Note do
  @moduledoc """
  Defines the data schema for the business partners`Note` entity,
  annotations of business partners.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          note: String.t(),
          business_partner_id: binary()
        }
  schema "business_partner_notes" do
    field :note, :string
    belongs_to :business_partner, BusinessPartner, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:note, :business_partner_id])
    |> validate_required([:note], message: "The message can't be empty")
    |> assoc_constraint(:business_partner)
  end
end
