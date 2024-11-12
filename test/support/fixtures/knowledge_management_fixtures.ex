defmodule Klepsidra.KnowledgeManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.KnowledgeManagement` context.
  """

  @doc """
  Generate a annotation.
  """
  def annotation_fixture(attrs \\ %{}) do
    {:ok, annotation} =
      attrs
      |> Enum.into(%{
        entry_type: "some entry_type",
        text: "some text",
        author_name: "some author_name",
        comment: "some comment",
        position_reference: "some position_reference"
      })
      |> Klepsidra.KnowledgeManagement.create_annotation()

    annotation
  end
end
