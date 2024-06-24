defmodule Klepsidra.BusinessPartnersTest do
  use Klepsidra.DataCase

  alias Klepsidra.BusinessPartners

  describe "business_partners" do
    alias Klepsidra.BusinessPartners.BusinessPartner

    import Klepsidra.BusinessPartnersFixtures

    @invalid_attrs %{active: nil, name: nil, description: nil, customer: nil, supplier: nil}

    test "list_business_partners/0 returns all business_partners" do
      business_partner = business_partner_fixture()
      assert BusinessPartners.list_business_partners() == [business_partner]
    end

    test "get_business_partner!/1 returns the business_partner with given id" do
      business_partner = business_partner_fixture()
      assert BusinessPartners.get_business_partner!(business_partner.id) == business_partner
    end

    test "create_business_partner/1 with valid data creates a business_partner" do
      valid_attrs = %{
        active: true,
        name: "some name",
        description: "some description",
        customer: true,
        supplier: true
      }

      assert {:ok, %BusinessPartner{} = business_partner} =
               BusinessPartners.create_business_partner(valid_attrs)

      assert business_partner.active == true
      assert business_partner.name == "some name"
      assert business_partner.description == "some description"
      assert business_partner.customer == true
      assert business_partner.supplier == true
    end

    test "create_business_partner/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               BusinessPartners.create_business_partner(@invalid_attrs)
    end

    test "update_business_partner/2 with valid data updates the business_partner" do
      business_partner = business_partner_fixture()

      update_attrs = %{
        active: false,
        name: "some updated name",
        description: "some updated description",
        customer: false,
        supplier: false
      }

      assert {:ok, %BusinessPartner{} = business_partner} =
               BusinessPartners.update_business_partner(business_partner, update_attrs)

      assert business_partner.active == false
      assert business_partner.name == "some updated name"
      assert business_partner.description == "some updated description"
      assert business_partner.customer == false
      assert business_partner.supplier == false
    end

    test "update_business_partner/2 with invalid data returns error changeset" do
      business_partner = business_partner_fixture()

      assert {:error, %Ecto.Changeset{}} =
               BusinessPartners.update_business_partner(business_partner, @invalid_attrs)

      assert business_partner == BusinessPartners.get_business_partner!(business_partner.id)
    end

    test "delete_business_partner/1 deletes the business_partner" do
      business_partner = business_partner_fixture()

      assert {:ok, %BusinessPartner{}} =
               BusinessPartners.delete_business_partner(business_partner)

      assert_raise Ecto.NoResultsError, fn ->
        BusinessPartners.get_business_partner!(business_partner.id)
      end
    end

    test "change_business_partner/1 returns a business_partner changeset" do
      business_partner = business_partner_fixture()
      assert %Ecto.Changeset{} = BusinessPartners.change_business_partner(business_partner)
    end
  end

  # describe "business_partner_notes" do
  #   alias Klepsidra.BusinessPartners.Note

  #   import Klepsidra.BusinessPartnersFixtures

  #   @invalid_attrs %{note: nil, user_id: nil, business_partner_id: nil}

  #   test "list_business_partner_notes/0 returns all business_partner_notes" do
  #     note = note_fixture()
  #     assert BusinessPartners.list_business_partner_notes() == [note]
  #   end

  #   test "get_note!/1 returns the note with given id" do
  #     note = note_fixture()
  #     assert BusinessPartners.get_note!(note.id) == note
  #   end

  #   test "create_note/1 with valid data creates a note" do
  #     valid_attrs = %{note: "some note", user_id: 42, business_partner_id: 42}

  #     assert {:ok, %Note{} = note} = BusinessPartners.create_note(valid_attrs)
  #     assert note.note == "some note"
  #     assert note.user_id == 42
  #     assert note.business_partner_id == 42
  #   end

  #   test "create_note/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = BusinessPartners.create_note(@invalid_attrs)
  #   end

  #   test "update_note/2 with valid data updates the note" do
  #     note = note_fixture()
  #     update_attrs = %{note: "some updated note", user_id: 43, business_partner_id: 43}

  #     assert {:ok, %Note{} = note} = BusinessPartners.update_note(note, update_attrs)
  #     assert note.note == "some updated note"
  #     assert note.user_id == 43
  #     assert note.business_partner_id == 43
  #   end

  #   test "update_note/2 with invalid data returns error changeset" do
  #     note = note_fixture()
  #     assert {:error, %Ecto.Changeset{}} = BusinessPartners.update_note(note, @invalid_attrs)
  #     assert note == BusinessPartners.get_note!(note.id)
  #   end

  #   test "delete_note/1 deletes the note" do
  #     note = note_fixture()
  #     assert {:ok, %Note{}} = BusinessPartners.delete_note(note)
  #     assert_raise Ecto.NoResultsError, fn -> BusinessPartners.get_note!(note.id) end
  #   end

  #   test "change_note/1 returns a note changeset" do
  #     note = note_fixture()
  #     assert %Ecto.Changeset{} = BusinessPartners.change_note(note)
  #   end
  # end
end
