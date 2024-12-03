defmodule Klepsidra.KnowledgeManagementFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.KnowledgeManagement` context.
  """

  @doc """
  Generate an annotation.
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

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    {:ok, notes} =
      attrs
      |> Enum.into(%{
        title: "some title",
        content: "some content",
        content_format: :markdown,
        rendered_content: "some rendered_content",
        rendered_content_format: :html,
        summary: "some summary",
        status: :draft,
        review_date: ~D[2024-12-02],
        pinned: true,
        attachments: %{},
        priority: 42
      })
      |> Klepsidra.KnowledgeManagement.create_notes()

    notes
  end
end
