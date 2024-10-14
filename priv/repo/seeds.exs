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

defmodule Klepsidra.Locations.FeatureClass.Seeds do
  alias Klepsidra.Locations

  @features_source_file "priv/data/featureCodes_en.csv"

  NimbleCSV.define(Klepsidra.Parsers.GeoNamesParser,
    separator: "\,",
    escape: "\"",
    newlines: ["\r\n", "\n"]
  )

  @features_source_file
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.parse_stream(skip_headers: false)
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

defmodule Klepsidra.Utilities.City.Seeds do
  @moduledoc false

  alias Klepsidra.Utilities

  @cities_source_file "priv/data/cities500.csv"
  @cities_record_separator ?,
  @cities_headers [
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
  ]

  NimbleCSV.define(Klepsidra.Parsers.GeoNamesParser,
    separator: "\,",
    escape: "\"",
    newlines: ["\r\n", "\n"]
  )

  @cities_source_file
  |> File.stream!(read_ahead: 100_000)
  |> Klepsidra.Parsers.GeoNamesParser.parse_stream(skip_headers: false)
  |> Stream.transform(nil, fn
    headers, nil ->
      {[], headers}

    row, headers ->
      {[Enum.zip(headers, row) |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)],
       headers}
  end)
  |> Stream.each(fn record -> Utilities.create_city(record) end)
  |> Stream.run()
end
