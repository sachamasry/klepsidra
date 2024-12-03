defmodule Klepsidra.KnowledgeManagementTest do
  use Klepsidra.DataCase

  alias Klepsidra.KnowledgeManagement

  describe "annotations" do
    alias Klepsidra.KnowledgeManagement.Annotation

    import Klepsidra.KnowledgeManagementFixtures

    @invalid_attrs %{
      entry_type: nil,
      text: nil,
      author_name: nil,
      comment: nil,
      position_reference: nil
    }

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert KnowledgeManagement.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert KnowledgeManagement.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      valid_attrs = %{
        entry_type: "some entry_type",
        text: "some text",
        author_name: "some author_name",
        comment: "some comment",
        position_reference: "some position_reference"
      }

      assert {:ok, %Annotation{} = annotation} =
               KnowledgeManagement.create_annotation(valid_attrs)

      assert annotation.text == "some text"
      assert annotation.comment == "some comment"
      assert annotation.entry_type == "some entry_type"
      assert annotation.author_name == "some author_name"
      assert annotation.position_reference == "some position_reference"
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()

      update_attrs = %{
        entry_type: "some updated entry_type",
        text: "some updated text",
        author_name: "some updated author_name",
        comment: "some updated comment",
        position_reference: "some updated position_reference"
      }

      assert {:ok, %Annotation{} = annotation} =
               KnowledgeManagement.update_annotation(annotation, update_attrs)

      assert annotation.text == "some updated text"
      assert annotation.comment == "some updated comment"
      assert annotation.entry_type == "some updated entry_type"
      assert annotation.author_name == "some updated author_name"
      assert annotation.position_reference == "some updated position_reference"
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               KnowledgeManagement.update_annotation(annotation, @invalid_attrs)

      assert annotation == KnowledgeManagement.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = KnowledgeManagement.delete_annotation(annotation)

      assert_raise Ecto.NoResultsError, fn ->
        KnowledgeManagement.get_annotation!(annotation.id)
      end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = KnowledgeManagement.change_annotation(annotation)
    end
  end

  describe "knowledge_management_notes" do
    alias Klepsidra.KnowledgeManagement.Note

    import Klepsidra.KnowledgeManagementFixtures

    @invalid_attrs %{
      title: nil,
      content: nil,
      content_format: nil,
      rendered_content: nil,
      rendered_content_format: nil,
      summary: nil,
      status: nil,
      review_date: nil,
      pinned: nil,
      attachments: nil,
      priority: nil
    }

    test "list_knowledge_management_notes/0 returns all knowledge_management_notes" do
      notes = note_fixture()
      assert KnowledgeManagement.list_knowledge_management_notes() == [notes]
    end

    test "get_notes!/1 returns the notes with given id" do
      notes = note_fixture()
      assert KnowledgeManagement.get_notes!(notes.id) == notes
    end

    test "create_notes/1 with valid data creates a notes" do
      valid_attrs = %{
        title: "some title",
        content: "some content",
        content_format: :markdown,
        rendered_content: "<p>\nsome content</p>\n",
        rendered_content_format: :html,
        summary: "some summary",
        status: :draft,
        review_date: ~D[2024-12-02],
        pinned: true,
        attachments: %{},
        priority: 42
      }

      assert {:ok, %Note{} = notes} = KnowledgeManagement.create_notes(valid_attrs)
      assert notes.priority == 42
      assert notes.status == :draft
      assert notes.title == "some title"
      assert notes.content == "some content"
      assert notes.content_format == :markdown
      assert notes.rendered_content == "<p>\nsome content</p>\n"
      assert notes.rendered_content_format == :html
      assert notes.summary == "some summary"
      assert notes.review_date == ~D[2024-12-02]
      assert notes.pinned == true
      assert notes.attachments == %{}
    end

    test "create_notes/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_notes(@invalid_attrs)
    end

    test "update_notes/2 with valid data updates the notes" do
      notes = note_fixture()

      update_attrs = %{
        title: "some updated title",
        content: "some updated content",
        content_format: :"org-mode",
        rendered_content: "<p>\nsome updated content</p>\n",
        rendered_content_format: :pdf,
        summary: "some updated summary",
        status: :fleeting,
        review_date: ~D[2024-12-03],
        pinned: false,
        attachments: %{},
        priority: 43
      }

      assert {:ok, %Note{} = notes} = KnowledgeManagement.update_notes(notes, update_attrs)
      assert notes.priority == 43
      assert notes.status == :fleeting
      assert notes.title == "some updated title"
      assert notes.content == "some updated content"
      assert notes.content_format == :"org-mode"
      assert notes.rendered_content == "<p>\nsome updated content</p>\n"
      assert notes.rendered_content_format == :pdf
      assert notes.summary == "some updated summary"
      assert notes.review_date == ~D[2024-12-03]
      assert notes.pinned == false
      assert notes.attachments == %{}
    end

    test "update_notes/2 with invalid data returns error changeset" do
      notes = note_fixture()
      assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.update_notes(notes, @invalid_attrs)
      assert notes == KnowledgeManagement.get_notes!(notes.id)
    end

    test "delete_notes/1 deletes the notes" do
      notes = note_fixture()
      assert {:ok, %Note{}} = KnowledgeManagement.delete_notes(notes)
      assert_raise Ecto.NoResultsError, fn -> KnowledgeManagement.get_notes!(notes.id) end
    end

    test "change_notes/1 returns a notes changeset" do
      notes = note_fixture()
      assert %Ecto.Changeset{} = KnowledgeManagement.change_notes(notes)
    end
  end
end
