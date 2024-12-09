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
    {:ok, note} =
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
      |> Klepsidra.KnowledgeManagement.create_note()

    note
  end

  @doc """
  Generate a note_search.
  """
  def note_search_fixture(attrs \\ %{}) do
    {:ok, note_search} =
      attrs
      |> Enum.into(%{
        rowid: 2,
        id: "7488a646-e31f-11e4-aace-600308960662",
        title: "some title",
        content: "some content",
        summary: "some summary",
        tags: "test · design · learning"
      })
      |> Klepsidra.KnowledgeManagement.create_note_search()

    note_search
  end

  @doc """
  Generate a note_tags.
  """
  def note_tags_fixture(attrs \\ %{}) do
    {:ok, note_tags} =
      attrs
      |> Enum.into(%{
        note_id: "7488a646-e31f-11e4-aace-600308960662",
        tag_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Klepsidra.KnowledgeManagement.create_note_tags()

    note_tags
  end
end
