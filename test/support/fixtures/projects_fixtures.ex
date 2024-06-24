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

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    {:ok, note} =
      attrs
      |> Enum.into(%{
        note: "some note",
        project_id: 42,
        user_id: 42
      })
      |> Klepsidra.Projects.create_note()

    note
  end
end
