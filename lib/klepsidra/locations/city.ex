defmodule Klepsidra.Locations.City do
  @moduledoc """
  Defines a schema for the `City` entity, used to select cities of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the `cities500.zip`
  file, all cities with a population greater than 500.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          geoname_id: integer(),
          name: String.t(),
          asciiname: String.t(),
          alternatenames: String.t(),
          latitude: float(),
          longitude: float(),
          feature_class: String.t(),
          feature_code: String.t(),
          country_code: String.t(),
          cc2: String.t(),
          admin1_code: String.t(),
          admin2_code: String.t(),
          admin3_code: String.t(),
          admin4_code: String.t(),
          population: integer(),
          elevation: integer(),
          dem: integer(),
          timezone: String.t(),
          modification_date: Date.t()
        }
  schema "locations_cities" do
    field :geoname_id, :integer
    field :name, :string
    field :asciiname, :string
    field :alternatenames, :string
    field :latitude, :float
    field :longitude, :float
    field :feature_class, :string
    field :feature_code, :string
    field :country_code, :string
    field :cc2, :string
    field :admin1_code, :string
    field :admin2_code, :string
    field :admin3_code, :string
    field :admin4_code, :string
    field :population, :integer
    field :elevation, :integer
    field :dem, :integer
    field :timezone, :string
    field :modification_date, :date

    timestamps()
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [
      :geoname_id,
      :name,
      :asciiname,
      :alternatenames,
      :latitude,
      :longitude,
      :feature_class,
      :feature_code,
      :country_code,
      :cc2,
      :admin1_code,
      :admin2_code,
      :admin3_code,
      :admin4_code,
      :population,
      :elevation,
      :dem,
      :timezone,
      :modification_date
    ])
    |> validate_required([
      :geoname_id,
      :name,
      :latitude,
      :longitude,
      :feature_class,
      :feature_code,
      :country_code,
      :population,
      :timezone,
      :modification_date
    ])
  end
end
