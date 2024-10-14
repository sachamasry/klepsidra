defmodule Klepsidra.LocationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Locations` context.
  """

  @doc """
  Generate a feature_class.
  """
  def feature_class_fixture(attrs \\ %{}) do
    {:ok, feature_class} =
      attrs
      |> Enum.into(%{
        description: "some description",
        feature_class: "some feature_class",
        feature_code: "some feature_code",
        note: "some note",
        order: 42
      })
      |> Klepsidra.Locations.create_feature_class()

    feature_class
  end
end
