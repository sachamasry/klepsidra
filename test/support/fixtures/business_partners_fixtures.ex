defmodule Klepsidra.BusinessPartnersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.BusinessPartners` context.
  """

  @doc """
  Generate a business_partner.
  """
  def business_partner_fixture(attrs \\ %{}) do
    {:ok, business_partner} =
      attrs
      |> Enum.into(%{
        active: true,
        customer: true,
        description: "some description",
        name: "some name",
        supplier: true
      })
      |> Klepsidra.BusinessPartners.create_business_partner()

    business_partner
  end
end
