# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Klepsidra.Repo.insert!(%Klepsidra.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

NimbleCSV.define(Klepsidra.Parsers.GeoNamesParser.CommaDelimited,
  separator: "\,",
  escape: "\"",
  newlines: ["\r\n", "\n"]
)

NimbleCSV.define(Klepsidra.Parsers.GeoNamesParser.TabDelimited,
  separator: "\t",
  escape: "\"",
  newlines: ["\r\n", "\n"]
)

defmodule Seeds.Utilities do
  def split_last_component_from_key(
        composite_key,
        delimiter \\ ".",
        number_of_subcomponents_to_remove \\ 1
      ) do
    composite_key
    |> String.split(delimiter)
    |> Enum.drop(-number_of_subcomponents_to_remove)
    |> Enum.join(delimiter)
  end
end

defmodule Klepsidra.Locations.FeatureClass.Seeds do
  alias Klepsidra.Locations

  "priv/data/feature_classes.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.each(fn record ->
    Locations.create_feature_class(record)
  end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.FeatureCode.Seeds do
  alias Klepsidra.Locations

  "priv/data/featureCodes_en.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} ->
           {String.to_atom(k), v}
         end)
       ], headers}
  end)
  |> Stream.map(fn record ->
    Map.merge(record, %{
      feature_class: Seeds.Utilities.split_last_component_from_key(record.feature_code, ".", 1)
    })
  end)
  |> Stream.each(fn record ->
    Locations.create_feature_code(record)
  end)
  |> Stream.run()
end

defmodule Klepsidra.Localisation.Languages.Seeds do
  alias Klepsidra.Localisation

  "priv/data/iso-languagecodes-cleansed.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.each(fn record -> Localisation.create_language(record) end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.Continents.Seeds do
  alias Klepsidra.Locations

  "priv/data/continent_codes.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.each(fn record -> Locations.create_continent(record) end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.Countries.Seeds do
  alias Klepsidra.Locations

  "priv/data/countryInfo-cleansed.txt"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.TabDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.each(fn record -> Locations.create_country(record) end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.AdministrativeDivisions1.Seeds do
  alias Klepsidra.Locations

  "priv/data/admin1CodesASCII.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.map(fn record ->
    Map.merge(record, %{
      country_code:
        Seeds.Utilities.split_last_component_from_key(
          record.administrative_division_1_code,
          ".",
          1
        )
    })
  end)
  |> Stream.each(fn record -> Locations.create_administrative_division_1(record) end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.AdministrativeDivisions2.Seeds do
  alias Klepsidra.Locations

  "priv/data/admin2Codes.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[
         Enum.zip(headers, row)
         |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
       ], headers}
  end)
  |> Stream.map(fn record ->
    Map.merge(record, %{
      administrative_division_1_code:
        Seeds.Utilities.split_last_component_from_key(
          record.administrative_division_2_code,
          ".",
          1
        ),
      country_code:
        Seeds.Utilities.split_last_component_from_key(
          record.administrative_division_2_code,
          ".",
          2
        )
    })
  end)
  |> Stream.each(fn record -> Locations.create_administrative_division_2(record) end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.City.Seeds do
  @moduledoc false

  alias Klepsidra.Locations

  "priv/data/cities500.csv"
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[Enum.zip(headers, row) |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)],
       headers}
  end)
  |> Stream.map(fn record ->
    Map.merge(record, %{
      feature_code: "#{record.feature_class}.#{record.feature_code}",
      administrative_division_1_code:
        if record.administrative_division_1_code != "" do
          "#{record.country_code}.#{record.administrative_division_1_code}"
        end,
      administrative_division_2_code:
        if record.administrative_division_2_code != "" do
          "#{record.country_code}.#{record.administrative_division_1_code}.#{record.administrative_division_2_code}"
        end
    })
  end)
  |> Stream.each(fn record -> Klepsidra.Locations.create_city(record) end)
  |> Stream.run()
end
