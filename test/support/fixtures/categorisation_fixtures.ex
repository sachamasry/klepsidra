defmodule Klepsidra.CategorisationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Categorisation` context.
  """

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        colour: "some colour",
        description: "some description",
        name: "some tag"
      })
      |> Klepsidra.Categorisation.create_tag()

    tag
  end
end
