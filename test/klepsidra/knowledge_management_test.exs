defmodule Klepsidra.KnowledgeManagementTest do
  use Klepsidra.DataCase

  alias Klepsidra.KnowledgeManagement

  describe "annotations" do
    alias Klepsidra.KnowledgeManagement.Annotation

    import Klepsidra.KnowledgeManagementFixtures

    @invalid_attrs %{
      id: nil,
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
        id: "some id",
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
        id: "some updated id",
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
end
