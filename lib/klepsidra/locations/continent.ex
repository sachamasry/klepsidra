defmodule Klepsidra.Locations.Continent do
  @moduledoc """
  Defines a schema for the `Continents` entity, listing continents of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the
  `continent_codes.csv` file (itself generated from the description on
  https://download.geonames.org/export/dump/), with column headers added.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{
          continent_code: String.t(),
          continent_name: String.t(),
          geoname_id: integer()
        }
  schema "locations_continents" do
    field(:continent_code, :string, primary_key: true)
    field(:continent_name, :string)
    field(:geoname_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(continent, attrs) do
    continent
    |> cast(attrs, [:continent_code, :continent_name, :geoname_id])
    |> unique_constraint(:continent_code)
    |> validate_required([:continent_code, :continent_name, :geoname_id])
  end
end
