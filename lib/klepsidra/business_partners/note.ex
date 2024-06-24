defmodule Klepsidra.BusinessPartners.Note do
  @moduledoc """
  Defines the data schema for the business partners`Note` entity,
  annotations of business partners.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          note: String.t(),
          user_id: integer,
          business_partner_id: integer
        }
  schema "business_partner_notes" do
    field :note, :string
    field :user_id, :integer
    field :business_partner_id, :integer

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:note, :user_id, :business_partner_id])
    |> validate_required([:note])
  end
end
