defmodule Klepsidra.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Documents` context.
  """

  @doc """
  Generate a document_issuer.
  """
  def document_issuer_fixture(attrs \\ %{}) do
    {:ok, document_issuer} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        country_id: nil,
        contact_information: %{
          "email" => "contact@authority.gov",
          "phone" => "+1-202-555-0198",
          "address" => "123 Government Street, Washington, DC",
          "working_hours" => "Mon-Fri, 9 AM - 5 PM"
        },
        website_url: "some website_url"
      })
      |> Klepsidra.Documents.create_document_issuer()

    document_issuer
  end

  @doc """
  Generate a document_type.
  """
  def document_type_fixture(attrs \\ %{}) do
    {:ok, document_type} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        max_validity_period_unit: "year",
        max_validity_duration: 10,
        is_country_specific: true,
        requires_renewal: true
      })
      |> Klepsidra.Documents.create_document_type()

    document_type
  end

  @doc """
  Generate a user_document.
  """
  def user_document_fixture(attrs \\ %{}) do
    {:ok, user_document} =
      attrs
      |> Enum.into(%{
        document_type_id: "7488a646-e31f-11e4-aace-600308960662",
        expiry_date: ~D[2024-11-19],
        file_url: "some file_url",
        id: "7488a646-e31f-11e4-aace-600308960662",
        is_active: true,
        issue_date: ~D[2024-11-19],
        issued_by: "some issued_by",
        issuing_country_id: "some issuing_country_id",
        unique_reference: "some unique_reference",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Klepsidra.Documents.create_user_document()

    user_document
  end
end
