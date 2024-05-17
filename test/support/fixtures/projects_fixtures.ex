defmodule Klepsidra.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        active: true,
        description: "some description",
        name: "some name"
      })
      |> Klepsidra.Projects.create_project()

    project
  end
end
