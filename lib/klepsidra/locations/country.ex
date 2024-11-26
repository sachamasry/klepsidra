defmodule Klepsidra.Locations.Country do
  @moduledoc """
  Defines a schema for the `Country` entity, listing the countries of the world.

  This is not meant to be a user-editable entity, imported on a periodic basis
  from the [Geonames](https://geonames.org) project, specifically the `countryInfo.txt`
  file, all countries' information, with the file annotation headers stripped off
  and column headers converted to lowercase, underscore-separated names.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Locations

  @primary_key false
  @type t :: %__MODULE__{
          iso_country_code: String.t(),
          iso_3_country_code: String.t(),
          iso_numeric_country_code: integer(),
          fips_country_code: String.t(),
          country_name: String.t(),
          capital: String.t(),
          area: float(),
          population: integer(),
          continent_code: String.t(),
          tld: String.t(),
          currency_code: String.t(),
          currency_name: String.t(),
          phone: String.t(),
          postal_code_format: String.t(),
          postal_code_regex: String.t(),
          languages: String.t(),
          geoname_id: integer(),
          neighbours: String.t(),
          equivalent_fips_code: String.t()
        }
  schema "locations_countries" do
    field(:iso_country_code, :string, primary_key: true)
    field(:iso_3_country_code, :string)
    field(:iso_numeric_country_code, :integer)
    field(:fips_country_code, :string)
    field(:country_name, :string)
    field(:capital, :string)
    field(:area, :float)
    field(:population, :integer)
    field(:continent_code, :string)
    field(:tld, :string)
    field(:currency_code, :string)
    field(:currency_name, :string)
    field(:phone, :string)
    field(:postal_code_format, :string)
    field(:postal_code_regex, :string)
    field(:languages, :string)
    field(:geoname_id, :integer)
    field(:neighbours, :string)
    field(:equivalent_fips_code, :string)

    timestamps()
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [
      :iso_country_code,
      :iso_3_country_code,
      :iso_numeric_country_code,
      :fips_country_code,
      :country_name,
      :capital,
      :area,
      :population,
      :continent_code,
      :tld,
      :currency_code,
      :currency_name,
      :phone,
      :postal_code_format,
      :postal_code_regex,
      :languages,
      :geoname_id,
      :neighbours,
      :equivalent_fips_code
    ])
    |> unique_constraint([
      :iso_country_code,
      :iso_3_country_code,
      :iso_numeric_country_code,
      :geoname_id
    ])
    |> foreign_key_constraint(:continent_code)
    |> validate_required([
      :iso_country_code,
      :iso_3_country_code,
      :iso_numeric_country_code,
      :country_name,
      :area,
      :population,
      :continent_code,
      :geoname_id
    ])
  end

  @doc """
  Constructs an HTML `select` option for a single country entity, for use by
  the `live_select` live component.

  Given a current `country_id`, a foreign key reference to a country in the
  `locations_countries` table, calls the `get_country_by_iso_3_code!/1`
  query, obtaining necessary fields to construct a full, unambiguous,
  country name.

  ## Returns

  Returns a single map:
  ```
  %{
    label: << country_name >>,
    value: << iso_3_country_code (string) >>
  ```

  ## Examples

      iex> country_option_as_html_select("GBR")
      %{label: "...", value: "..."}

      iex> country_option_as_html_select(123)
      %{label: "", value: ""}
  """
  @spec country_option_for_select(country_code :: String.t()) :: %{
          label: String.t(),
          value: String.t()
        }
  def country_option_for_select(country_code) when is_bitstring(country_code) do
    case Locations.get_country_by_iso_3_code!(country_code) do
      nil ->
        %{label: "", value: ""}

      country ->
        country
    end
  end

  def country_option_as_html_select(_), do: %{label: "", value: ""}
end
