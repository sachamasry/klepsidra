defmodule Klepsidra.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Documents` context.
  """

  @doc """
  Generate a document_type.
  """
  def document_type_fixture(attrs \\ %{}) do
    {:ok, document_type} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description"
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
