defmodule Klepsidra.LocalisationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Localisation` context.
  """

  @doc """
  Generate a language.
  """
  def language_fixture(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        "iso_639-1": "some iso_639-1",
        "iso_639-2": "some iso_639-2",
        "iso_639-3": "some iso_639-3",
        language_name: "some language_name"
      })
      |> Klepsidra.Localisation.create_language()

    language
  end
end
