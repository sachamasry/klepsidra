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
end
