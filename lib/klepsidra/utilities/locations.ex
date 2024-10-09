defmodule Klepsidra.Locations do
  @moduledoc """
  Location utilities for countries, subdivisions and cities.

  The module is largely a wrapper for Plausible Analytics'
  [`Location` package](https://github.com/plausible/location/tree/main).
  """

  @ets_cities Location.City.ByLabel

  @doc false
  def search_city(search_phrase) do
    search_phrase = String.downcase(search_phrase)

    :ets.foldl(
      fn
        {{name, country_code}, _id}, acc ->
          if String.contains?(String.downcase(name), search_phrase) do
            country = Location.get_country(country_code)
            [{name, country_code, country.name, country.flag} | acc]
          else
            acc
          end
      end,
      [],
      @ets_cities
      # Location.City.ByLabel
    )
    |> Enum.sort_by(fn {city, _country_code, country_name, _flag} ->
      {!String.starts_with?(city, search_phrase), byte_size(city), country_name}
    end)
    |> Enum.map(fn {city, _country_code, country_name, flag} ->
      "#{city} - #{country_name}  #{flag}"
    end)
  end
end
