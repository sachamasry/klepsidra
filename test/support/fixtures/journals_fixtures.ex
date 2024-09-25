defmodule Klepsidra.JournalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Journals` context.
  """

  @doc """
  Generate a journal_entry.
  """
  def journal_entry_fixture(attrs \\ %{}) do
    {:ok, journal_entry} =
      attrs
      |> Enum.into(%{
        journal_for: "2024-01-02",
        entry_text_html: "some entry_text_html",
        entry_text_markdown: "some entry_text_markdown",
        is_private: true,
        is_short_entry: true,
        mood: "some mood"
      })
      |> Klepsidra.Journals.create_journal_entry()

    journal_entry
  end

  @doc """
  Generate a journal_entry_types.
  """
  def journal_entry_types_fixture(attrs \\ %{}) do
    {:ok, journal_entry_types} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Klepsidra.Journals.create_journal_entry_types()

    journal_entry_types
  end
end
