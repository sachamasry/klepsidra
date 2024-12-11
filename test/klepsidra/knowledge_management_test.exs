defmodule Klepsidra.KnowledgeManagementTest do
  use Klepsidra.DataCase

  alias Klepsidra.KnowledgeManagement

  # describe "annotations" do
  #   alias Klepsidra.KnowledgeManagement.Annotation

  #   import Klepsidra.KnowledgeManagementFixtures

  #   @invalid_attrs %{
  #     entry_type: nil,
  #     text: nil,
  #     author_name: nil,
  #     comment: nil,
  #     position_reference: nil
  #   }

  #   test "list_annotations/0 returns all annotations" do
  #     annotation = annotation_fixture()
  #     assert KnowledgeManagement.list_annotations() == [annotation]
  #   end

  #   test "get_annotation!/1 returns the annotation with given id" do
  #     annotation = annotation_fixture()
  #     assert KnowledgeManagement.get_annotation!(annotation.id) == annotation
  #   end

  #   test "create_annotation/1 with valid data creates a annotation" do
  #     valid_attrs = %{
  #       entry_type: "some entry_type",
  #       text: "some text",
  #       author_name: "some author_name",
  #       comment: "some comment",
  #       position_reference: "some position_reference"
  #     }

  #     assert {:ok, %Annotation{} = annotation} =
  #              KnowledgeManagement.create_annotation(valid_attrs)

  #     assert annotation.text == "some text"
  #     assert annotation.comment == "some comment"
  #     assert annotation.entry_type == "some entry_type"
  #     assert annotation.author_name == "some author_name"
  #     assert annotation.position_reference == "some position_reference"
  #   end

  #   test "create_annotation/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_annotation(@invalid_attrs)
  #   end

  #   test "update_annotation/2 with valid data updates the annotation" do
  #     annotation = annotation_fixture()

  #     update_attrs = %{
  #       entry_type: "some updated entry_type",
  #       text: "some updated text",
  #       author_name: "some updated author_name",
  #       comment: "some updated comment",
  #       position_reference: "some updated position_reference"
  #     }

  #     assert {:ok, %Annotation{} = annotation} =
  #              KnowledgeManagement.update_annotation(annotation, update_attrs)

  #     assert annotation.text == "some updated text"
  #     assert annotation.comment == "some updated comment"
  #     assert annotation.entry_type == "some updated entry_type"
  #     assert annotation.author_name == "some updated author_name"
  #     assert annotation.position_reference == "some updated position_reference"
  #   end

  #   test "update_annotation/2 with invalid data returns error changeset" do
  #     annotation = annotation_fixture()

  #     assert {:error, %Ecto.Changeset{}} =
  #              KnowledgeManagement.update_annotation(annotation, @invalid_attrs)

  #     assert annotation == KnowledgeManagement.get_annotation!(annotation.id)
  #   end

  #   test "delete_annotation/1 deletes the annotation" do
  #     annotation = annotation_fixture()
  #     assert {:ok, %Annotation{}} = KnowledgeManagement.delete_annotation(annotation)

  #     assert_raise Ecto.NoResultsError, fn ->
  #       KnowledgeManagement.get_annotation!(annotation.id)
  #     end
  #   end

  #   test "change_annotation/1 returns a annotation changeset" do
  #     annotation = annotation_fixture()
  #     assert %Ecto.Changeset{} = KnowledgeManagement.change_annotation(annotation)
  #   end
  # end

  # describe "knowledge_management_notes" do
  #   alias Klepsidra.KnowledgeManagement.Note

  #   import Klepsidra.KnowledgeManagementFixtures

  #   @invalid_attrs %{
  #     title: nil,
  #     content: nil,
  #     content_format: nil,
  #     rendered_content: nil,
  #     rendered_content_format: nil,
  #     summary: nil,
  #     status: nil,
  #     review_date: nil,
  #     pinned: nil,
  #     attachments: nil,
  #     priority: nil
  #   }

  #   test "list_knowledge_management_notes/0 returns all knowledge management notes" do
  #     note = note_fixture()
  #     assert KnowledgeManagement.list_knowledge_management_notes() == [note]
  #   end

  #   test "get_note!/1 returns the note with given id" do
  #     note = note_fixture()
  #     assert KnowledgeManagement.get_note!(note.id) == note
  #   end

  #   test "create_note/1 with valid data creates a note" do
  #     valid_attrs = %{
  #       title: "some title",
  #       content: "some content",
  #       content_format: :markdown,
  #       rendered_content: "<p>\nsome content</p>\n",
  #       rendered_content_format: :html,
  #       summary: "some summary",
  #       status: :draft,
  #       review_date: ~D[2024-12-02],
  #       pinned: true,
  #       attachments: %{},
  #       priority: 42
  #     }

  #     assert {:ok, %Note{} = note} = KnowledgeManagement.create_note(valid_attrs)
  #     assert note.priority == 42
  #     assert note.status == :draft
  #     assert note.title == "some title"
  #     assert note.content == "some content"
  #     assert note.content_format == :markdown
  #     assert note.rendered_content == "<p>\nsome content</p>\n"
  #     assert note.rendered_content_format == :html
  #     assert note.summary == "some summary"
  #     assert note.review_date == ~D[2024-12-02]
  #     assert note.pinned == true
  #     assert note.attachments == %{}
  #   end

  #   test "create_note/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_note(@invalid_attrs)
  #   end

  #   test "update_note/2 with valid data updates the note" do
  #     note = note_fixture()

  #     update_attrs = %{
  #       title: "some updated title",
  #       content: "some updated content",
  #       content_format: :"org-mode",
  #       rendered_content: "<p>\nsome updated content</p>\n",
  #       rendered_content_format: :pdf,
  #       summary: "some updated summary",
  #       status: :fleeting,
  #       review_date: ~D[2024-12-03],
  #       pinned: false,
  #       attachments: %{},
  #       priority: 43
  #     }

  #     assert {:ok, %Note{} = note} = KnowledgeManagement.update_note(note, update_attrs)
  #     assert note.priority == 43
  #     assert note.status == :fleeting
  #     assert note.title == "some updated title"
  #     assert note.content == "some updated content"
  #     assert note.content_format == :"org-mode"
  #     assert note.rendered_content == "<p>\nsome updated content</p>\n"
  #     assert note.rendered_content_format == :pdf
  #     assert note.summary == "some updated summary"
  #     assert note.review_date == ~D[2024-12-03]
  #     assert note.pinned == false
  #     assert note.attachments == %{}
  #   end

  #   test "update_note/2 with invalid data returns error changeset" do
  #     note = note_fixture()
  #     assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.update_note(note, @invalid_attrs)
  #     assert note == KnowledgeManagement.get_note!(note.id)
  #   end

  #   test "delete_note/1 deletes the note" do
  #     note = note_fixture()
  #     assert {:ok, %Note{}} = KnowledgeManagement.delete_note(note)
  #     assert_raise Ecto.NoResultsError, fn -> KnowledgeManagement.get_note!(note.id) end
  #   end

  #   test "change_note/1 returns a note changeset" do
  #     note = note_fixture()
  #     assert %Ecto.Changeset{} = KnowledgeManagement.change_note(note)
  #   end
  # end

  # describe "knowledge_management_note_tags" do
  #   alias Klepsidra.KnowledgeManagement.NoteTags

  #   import Klepsidra.KnowledgeManagementFixtures

  #   @invalid_attrs %{note_id: nil, tag_id: nil}

  #   # test "list_knowledge_management_note_tags/0 returns all knowledge_management_note_tags" do
  #   #   note_tags = note_tags_fixture()
  #   #   assert KnowledgeManagement.list_knowledge_management_note_tags() == [note_tags]
  #   # end

  #   # test "get_note_tags!/1 returns the note_tags with given id" do
  #   #   note_tags = note_tags_fixture()
  #   #   assert KnowledgeManagement.get_note_tags!(note_tags.id) == note_tags
  #   # end

  #   # test "create_note_tags/1 with valid data creates a note_tags" do
  #   #   valid_attrs = %{
  #   #     note_id: "7488a646-e31f-11e4-aace-600308960662",
  #   #     tag_id: "7488a646-e31f-11e4-aace-600308960662"
  #   #   }

  #   #   assert {:ok, %NoteTags{} = note_tags} = KnowledgeManagement.create_note_tags(valid_attrs)
  #   #   assert note_tags.note_id == "7488a646-e31f-11e4-aace-600308960662"
  #   #   assert note_tags.tag_id == "7488a646-e31f-11e4-aace-600308960662"
  #   # end

  #   # test "create_note_tags/1 with invalid data returns error changeset" do
  #   #   assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_note_tags(@invalid_attrs)
  #   # end

  #   # test "update_note_tags/2 with valid data updates the note_tags" do
  #   #   note_tags = note_tags_fixture()

  #   #   update_attrs = %{
  #   #     note_id: "7488a646-e31f-11e4-aace-600308960668",
  #   #     tag_id: "7488a646-e31f-11e4-aace-600308960668"
  #   #   }

  #   #   assert {:ok, %NoteTags{} = note_tags} =
  #   #            KnowledgeManagement.update_note_tags(note_tags, update_attrs)

  #   #   assert note_tags.note_id == "7488a646-e31f-11e4-aace-600308960668"
  #   #   assert note_tags.tag_id == "7488a646-e31f-11e4-aace-600308960668"
  #   # end

  #   # test "update_note_tags/2 with invalid data returns error changeset" do
  #   #   note_tags = note_tags_fixture()

  #   #   assert {:error, %Ecto.Changeset{}} =
  #   #            KnowledgeManagement.update_note_tags(note_tags, @invalid_attrs)

  #   #   assert note_tags == KnowledgeManagement.get_note_tags!(note_tags.id)
  #   # end

  #   # test "delete_note_tags/1 deletes the note_tags" do
  #   #   note_tags = note_tags_fixture()
  #   #   assert {:ok, %NoteTags{}} = KnowledgeManagement.delete_note_tags(note_tags)
  #   #   assert_raise Ecto.NoResultsError, fn -> KnowledgeManagement.get_note_tags!(note_tags.id) end
  #   # end

  #   # test "change_note_tags/1 returns a note_tags changeset" do
  #   #   note_tags = note_tags_fixture()
  #   #   assert %Ecto.Changeset{} = KnowledgeManagement.change_note_tags(note_tags)
  #   # end
  # end

  # describe "knowledge_management_notes_search" do
  #   alias Klepsidra.KnowledgeManagement.NoteSearch

  #   import Klepsidra.KnowledgeManagementFixtures

  #   @invalid_attrs %{id: nil, title: nil, content: nil, summary: nil, tags: nil}

  #   test "list_knowledge_management_notes_search/0 returns all knowledge_management_notes_search" do
  #     note_search = note_search_fixture()
  #     assert KnowledgeManagement.list_knowledge_management_notes_search() == [note_search]
  #   end

  #   test "get_note_search!/1 returns the note_search with given id" do
  #     note_search = note_search_fixture()
  #     assert KnowledgeManagement.get_note_search!(note_search.id) == note_search
  #   end

  #   test "create_note_search/1 with valid data creates a note_search" do
  #     valid_attrs = %{
  #       rowid: 1,
  #       id: "7488a646-e31f-11e4-aace-600308960662",
  #       title: "some title",
  #       content: "some content",
  #       summary: "some summary",
  #       tags: "shopping · riding · tennis"}

  #     assert {:ok, %NoteSearch{} = note_search} =
  #              KnowledgeManagement.create_note_search(valid_attrs)

  #     assert note_search.id == "7488a646-e31f-11e4-aace-600308960662"
  #     assert note_search.title == "some title"
  #     assert note_search.content == "some content"
  #     assert note_search.summary == "some summary"
  #     assert note_search.tags == "shopping · riding · tennis"
  #   end

  #   test "create_note_search/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = KnowledgeManagement.create_note_search(@invalid_attrs)
  #   end

  #   test "update_note_search/2 with valid data updates the note_search" do
  #     note_search = note_search_fixture()

  #     update_attrs = %{
  #       rowid: 1,
  #       id: "7488a646-e31f-11e4-aace-600308960668",
  #       title: "some updated title",
  #       content: "some updated content",
  #       summary: "some updated summary",
  #       tags: "golf · riding · polo"
  #     }

  #     assert {:ok, %NoteSearch{} = note_search} =
  #              KnowledgeManagement.update_note_search(note_search, update_attrs)

  #     assert note_search.id == "7488a646-e31f-11e4-aace-600308960668"
  #     assert note_search.title == "some updated title"
  #     assert note_search.content == "some updated content"
  #     assert note_search.summary == "some updated summary"
  #     assert note_search.summary == "golf · riding · polo"
  #   end

  #   test "update_note_search/2 with invalid data returns error changeset" do
  #     note_search = note_search_fixture()

  #     assert {:error, %Ecto.Changeset{}} =
  #              KnowledgeManagement.update_note_search(note_search, @invalid_attrs)

  #     assert note_search == KnowledgeManagement.get_note_search!(note_search.id)
  #   end

  #   test "delete_note_search/1 deletes the note_search" do
  #     note_search = note_search_fixture()
  #     assert {:ok, %NoteSearch{}} = KnowledgeManagement.delete_note_search(note_search)

  #     assert_raise Ecto.NoResultsError, fn ->
  #       KnowledgeManagement.get_note_search!(note_search.id)
  #     end
  #   end

  #   test "change_note_search/1 returns a note_search changeset" do
  #     note_search = note_search_fixture()
  #     assert %Ecto.Changeset{} = KnowledgeManagement.change_note_search(note_search)
  #   end
  # end

  describe "knowledge_management_relationship_types" do
    alias Klepsidra.KnowledgeManagement.RelationshipType

    import Klepsidra.KnowledgeManagementFixtures

    @invalid_attrs %{name: nil, description: nil, is_predefined: nil}

    test "list_knowledge_management_relationship_types/0 returns all knowledge_management_relationship_types" do
      relationship_type = relationship_type_fixture()

      assert KnowledgeManagement.list_knowledge_management_relationship_types() == [
               relationship_type
             ]
    end

    test "get_relationship_type!/1 returns the relationship_type with given id" do
      relationship_type = relationship_type_fixture()
      assert KnowledgeManagement.get_relationship_type!(relationship_type.id) == relationship_type
    end

    test "create_relationship_type/1 with valid data creates a relationship_type" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        is_predefined: true
      }

      assert {:ok, %RelationshipType{} = relationship_type} =
               KnowledgeManagement.create_relationship_type(valid_attrs)

      assert relationship_type.name == "some name"
      assert relationship_type.description == "some description"
      assert relationship_type.is_predefined == true
    end

    test "create_relationship_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               KnowledgeManagement.create_relationship_type(@invalid_attrs)
    end

    test "update_relationship_type/2 with valid data updates the relationship_type" do
      relationship_type = relationship_type_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        is_predefined: false
      }

      assert {:ok, %RelationshipType{} = relationship_type} =
               KnowledgeManagement.update_relationship_type(relationship_type, update_attrs)

      assert relationship_type.name == "some updated name"
      assert relationship_type.description == "some updated description"
      assert relationship_type.is_predefined == false
    end

    test "update_relationship_type/2 with invalid data returns error changeset" do
      relationship_type = relationship_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               KnowledgeManagement.update_relationship_type(relationship_type, @invalid_attrs)

      assert relationship_type == KnowledgeManagement.get_relationship_type!(relationship_type.id)
    end

    test "delete_relationship_type/1 deletes the relationship_type" do
      relationship_type = relationship_type_fixture()

      assert {:ok, %RelationshipType{}} =
               KnowledgeManagement.delete_relationship_type(relationship_type)

      assert_raise Ecto.NoResultsError, fn ->
        KnowledgeManagement.get_relationship_type!(relationship_type.id)
      end
    end

    test "change_relationship_type/1 returns a relationship_type changeset" do
      relationship_type = relationship_type_fixture()
      assert %Ecto.Changeset{} = KnowledgeManagement.change_relationship_type(relationship_type)
    end
  end
end
