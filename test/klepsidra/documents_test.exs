defmodule Klepsidra.DocumentsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Documents

  describe "document_types" do
    alias Klepsidra.Documents.DocumentType

    import Klepsidra.DocumentsFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_document_types/0 returns all document_types" do
      document_type = document_type_fixture()
      assert Documents.list_document_types() == [document_type]
    end

    test "get_document_type!/1 returns the document_type with given id" do
      document_type = document_type_fixture()
      assert Documents.get_document_type!(document_type.id) == document_type
    end

    test "create_document_type/1 with valid data creates a document_type" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %DocumentType{} = document_type} = Documents.create_document_type(valid_attrs)
      assert document_type.name == "some name"
      assert document_type.description == "some description"
    end

    test "create_document_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document_type(@invalid_attrs)
    end

    test "update_document_type/2 with valid data updates the document_type" do
      document_type = document_type_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %DocumentType{} = document_type} =
               Documents.update_document_type(document_type, update_attrs)

      assert document_type.name == "some updated name"
      assert document_type.description == "some updated description"
    end

    test "update_document_type/2 with invalid data returns error changeset" do
      document_type = document_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_document_type(document_type, @invalid_attrs)

      assert document_type == Documents.get_document_type!(document_type.id)
    end

    test "delete_document_type/1 deletes the document_type" do
      document_type = document_type_fixture()
      assert {:ok, %DocumentType{}} = Documents.delete_document_type(document_type)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_document_type!(document_type.id) end
    end

    test "change_document_type/1 returns a document_type changeset" do
      document_type = document_type_fixture()
      assert %Ecto.Changeset{} = Documents.change_document_type(document_type)
    end
  end
end
