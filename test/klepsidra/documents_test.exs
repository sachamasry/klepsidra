defmodule Klepsidra.DocumentsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Documents

  describe "document_issuers" do
    alias Klepsidra.Documents.DocumentIssuer

    import Klepsidra.DocumentsFixtures

    @invalid_attrs %{
      id: nil,
      name: nil,
      description: nil,
      country_id: nil,
      contact_information: nil,
      website_url: nil
    }

    test "list_document_issuers/0 returns all document_issuers" do
      document_issuer = document_issuer_fixture()
      assert Documents.simple_list_document_issuers() == [document_issuer]
    end

    test "get_document_issuer!/1 returns the document_issuer with given id" do
      document_issuer = document_issuer_fixture()
      assert Documents.get_document_issuer!(document_issuer.id) == document_issuer
    end

    test "create_document_issuer/1 with valid data creates a document_issuer" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        country_id: nil,
        contact_information: %{},
        website_url: "some website_url"
      }

      assert {:ok, %DocumentIssuer{} = document_issuer} =
               Documents.create_document_issuer(valid_attrs)

      assert document_issuer.name == "some name"
      assert document_issuer.description == "some description"
      assert document_issuer.country_id == nil
      assert document_issuer.contact_information == %{}
      assert document_issuer.website_url == "some website_url"
    end

    test "create_document_issuer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document_issuer(@invalid_attrs)
    end

    test "update_document_issuer/2 with valid data updates the document_issuer" do
      document_issuer = document_issuer_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        country_id: nil,
        contact_information: %{},
        website_url: "some updated website_url"
      }

      assert {:ok, %DocumentIssuer{} = document_issuer} =
               Documents.update_document_issuer(document_issuer, update_attrs)

      assert document_issuer.name == "some updated name"
      assert document_issuer.description == "some updated description"
      assert document_issuer.country_id == nil
      assert document_issuer.contact_information == %{}
      assert document_issuer.website_url == "some updated website_url"
    end

    test "update_document_issuer/2 with invalid data returns error changeset" do
      document_issuer = document_issuer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_document_issuer(document_issuer, @invalid_attrs)

      assert document_issuer == Documents.get_document_issuer!(document_issuer.id)
    end

    test "delete_document_issuer/1 deletes the document_issuer" do
      document_issuer = document_issuer_fixture()
      assert {:ok, %DocumentIssuer{}} = Documents.delete_document_issuer(document_issuer)

      assert_raise Ecto.NoResultsError, fn ->
        Documents.get_document_issuer!(document_issuer.id)
      end
    end

    test "change_document_issuer/1 returns a document_issuer changeset" do
      document_issuer = document_issuer_fixture()
      assert %Ecto.Changeset{} = Documents.change_document_issuer(document_issuer)
    end
  end

  describe "document_types" do
    alias Klepsidra.Documents.DocumentType

    import Klepsidra.DocumentsFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      max_validity_period_unit: nil,
      max_validity_duration: nil,
      is_country_specific: nil,
      requires_renewal: nil
    }

    test "list_document_types/0 returns all document_types" do
      document_type = document_type_fixture()
      assert Documents.list_document_types() == [document_type]
    end

    test "get_document_type!/1 returns the document_type with given id" do
      document_type = document_type_fixture()
      assert Documents.get_document_type!(document_type.id) == document_type
    end

    test "create_document_type/1 with valid data creates a document_type" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        max_validity_period_unit: "year",
        max_validity_duration: 10,
        is_country_specific: true,
        requires_renewal: true
      }

      assert {:ok, %DocumentType{} = document_type} = Documents.create_document_type(valid_attrs)
      assert document_type.name == "some name"
      assert document_type.description == "some description"
      assert document_type.max_validity_period_unit == "year"
      assert document_type.max_validity_duration == 10
      assert document_type.is_country_specific == true
      assert document_type.requires_renewal == true
    end

    test "create_document_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document_type(@invalid_attrs)
    end

    test "update_document_type/2 with valid data updates the document_type" do
      document_type = document_type_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        max_validity_period_unit: "month",
        max_validity_duration: 36,
        is_country_specific: false,
        requires_renewal: false
      }

      assert {:ok, %DocumentType{} = document_type} =
               Documents.update_document_type(document_type, update_attrs)

      assert document_type.name == "some updated name"
      assert document_type.description == "some updated description"
      assert document_type.max_validity_period_unit == "month"
      assert document_type.max_validity_duration == 36
      assert document_type.is_country_specific == false
      assert document_type.requires_renewal == false
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

  describe "user_documents" do
    # alias Klepsidra.Documents.UserDocument

    import Klepsidra.DocumentsFixtures

    # @invalid_attrs %{id: nil, document_type_id: nil, user_id: nil, unique_reference: nil, issued_by: nil, issuing_country_id: nil, issue_date: nil, expiry_date: nil, is_active: nil, file_url: nil}

    # test "list_user_documents/0 returns all user_documents" do
    #   user_document = user_document_fixture()
    #   assert Documents.list_user_documents() == [user_document]
    # end

    # test "get_user_document!/1 returns the user_document with given id" do
    #   user_document = user_document_fixture()
    #   assert Documents.get_user_document!(user_document.id) == user_document
    # end

    # test "create_user_document/1 with valid data creates a user_document" do
    #   valid_attrs = %{id: "7488a646-e31f-11e4-aace-600308960662", document_type_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662", unique_reference: "some unique_reference", issued_by: "some issued_by", issuing_country_id: "some issuing_country_id", issue_date: ~D[2024-11-19], expiry_date: ~D[2024-11-19], is_active: true, file_url: "some file_url"}

    #   assert {:ok, %UserDocument{} = user_document} = Documents.create_user_document(valid_attrs)
    #   assert user_document.id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert user_document.document_type_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert user_document.user_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert user_document.unique_reference == "some unique_reference"
    #   assert user_document.issued_by == "some issued_by"
    #   assert user_document.issuing_country_id == "some issuing_country_id"
    #   assert user_document.issue_date == ~D[2024-11-19]
    #   assert user_document.expiry_date == ~D[2024-11-19]
    #   assert user_document.is_active == true
    #   assert user_document.file_url == "some file_url"
    # end

    # test "create_user_document/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Documents.create_user_document(@invalid_attrs)
    # end

    # test "update_user_document/2 with valid data updates the user_document" do
    #   user_document = user_document_fixture()
    #   update_attrs = %{id: "7488a646-e31f-11e4-aace-600308960668", document_type_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668", unique_reference: "some updated unique_reference", issued_by: "some updated issued_by", issuing_country_id: "some updated issuing_country_id", issue_date: ~D[2024-11-20], expiry_date: ~D[2024-11-20], is_active: false, file_url: "some updated file_url"}

    #   assert {:ok, %UserDocument{} = user_document} = Documents.update_user_document(user_document, update_attrs)
    #   assert user_document.id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert user_document.document_type_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert user_document.user_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert user_document.unique_reference == "some updated unique_reference"
    #   assert user_document.issued_by == "some updated issued_by"
    #   assert user_document.issuing_country_id == "some updated issuing_country_id"
    #   assert user_document.issue_date == ~D[2024-11-20]
    #   assert user_document.expiry_date == ~D[2024-11-20]
    #   assert user_document.is_active == false
    #   assert user_document.file_url == "some updated file_url"
    # end

    # test "update_user_document/2 with invalid data returns error changeset" do
    #   user_document = user_document_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Documents.update_user_document(user_document, @invalid_attrs)
    #   assert user_document == Documents.get_user_document!(user_document.id)
    # end

    # test "delete_user_document/1 deletes the user_document" do
    #   user_document = user_document_fixture()
    #   assert {:ok, %UserDocument{}} = Documents.delete_user_document(user_document)
    #   assert_raise Ecto.NoResultsError, fn -> Documents.get_user_document!(user_document.id) end
    # end

    # test "change_user_document/1 returns a user_document changeset" do
    #   user_document = user_document_fixture()
    #   assert %Ecto.Changeset{} = Documents.change_user_document(user_document)
    # end
  end
end
