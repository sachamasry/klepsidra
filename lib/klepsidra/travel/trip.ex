defmodule Klepsidra.Travel.Trip do
  @moduledoc """
  Defines the `Trip` schema needed to record users' trips and stays
  between countries.

  This is useful not only for a historical travel record, but so that
  the system can monitor a user's travel with respect to a country's,
  or territory's visa allowances, and notify potential of overstaying
  past the allowance.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Locations.Country
  alias Klepsidra.Accounts.User

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          country_id: String.t(),
          description: String.t(),
          entry_date: Date.t(),
          exit_date: Date.t()
        }
  schema "trips" do
    belongs_to(:users, User, foreign_key: :user_id, type: Ecto.UUID)

    belongs_to(:locations_countries, Country,
      foreign_key: :country_id,
      references: :iso_3_country_code,
      type: :string
    )

    field :description, :string
    field :entry_date, :date
    field :exit_date, :date

    timestamps()
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [:user_id, :country_id, :description, :entry_date, :exit_date])
    |> validate_required([:user_id, :country_id, :entry_date])
  end
end