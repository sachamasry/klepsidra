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
end
