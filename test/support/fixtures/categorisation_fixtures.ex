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

  @doc """
  Generate a project_tag.
  """
  def project_tag_fixture(attrs \\ %{}) do
    {:ok, project_tag} =
      attrs
      |> Enum.into(%{
        project_id: 42,
        tag_id: 42
      })
      |> Klepsidra.Categorisation.create_project_tag()

    project_tag
  end
end
