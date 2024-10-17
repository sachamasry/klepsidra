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

defmodule Klepsidra.Locations.FeatureClass.Seeds do
  alias Klepsidra.Locations

  @features_source_file "priv/data/feature_classes.csv"

  @features_source_file
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

  @features_source_file "priv/data/featureCodes_en.csv"

  @features_source_file
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
    Locations.create_feature_code(record)
  end)
  |> Stream.run()
end

defmodule Klepsidra.Locations.Countries.Seeds do
  alias Klepsidra.Locations

  @countries_source_file "priv/data/countryInfo-cleansed.txt"

  @countries_source_file
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

defmodule Klepsidra.Locations.City.Seeds do
  @moduledoc false

  alias Klepsidra.Locations

  @cities_source_file "priv/data/cities500.csv"

  @cities_source_file
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.CommaDelimited.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[Enum.zip(headers, row) |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)],
       headers}
  end)
  |> Stream.each(fn record -> Klepsidra.Locations.create_city(record) end)
  |> Stream.run()
end
