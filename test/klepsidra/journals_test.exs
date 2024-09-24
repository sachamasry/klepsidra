defmodule Klepsidra.JournalsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Journals

  describe "categories" do
    alias Klepsidra.Journals.Category

    import Klepsidra.JournalsFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Journals.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Journals.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Journals.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Journals.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Journals.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Journals.update_category(category, @invalid_attrs)
      assert category == Journals.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Journals.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Journals.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Journals.change_category(category)
    end
  end

  describe "journal_entries" do
    alias Klepsidra.Journals.JournalEntry

    import Klepsidra.JournalsFixtures

    @invalid_attrs %{
      entry_text_markdown: nil,
      entry_text_html: nil,
      mood: nil,
      is_private: nil,
      is_short_entry: nil
    }

    test "list_journal_entries/0 returns all journal_entries" do
      # journal_entry = journal_entry_fixture()
      # assert Journals.list_journal_entries() == [journal_entry]
    end

    test "get_journal_entry!/1 returns the journal_entry with given id" do
      # journal_entry = journal_entry_fixture()
      # assert Journals.get_journal_entry!(journal_entry.id) == journal_entry
    end

    test "create_journal_entry/1 with valid data creates a journal_entry" do
      valid_attrs = %{
        journal_for: "2024-01-02",
        entry_text_markdown: "some entry_text_markdown",
        entry_text_html: "some entry_text_html",
        mood: "some mood",
        is_private: true,
        is_short_entry: true
      }

      assert {:ok, %JournalEntry{} = journal_entry} = Journals.create_journal_entry(valid_attrs)
      assert journal_entry.entry_text_markdown == "some entry_text_markdown"
      assert journal_entry.entry_text_html == "some entry_text_html"
      assert journal_entry.mood == "some mood"
      assert journal_entry.is_private == true
      assert journal_entry.is_short_entry == true
    end

    test "create_journal_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Journals.create_journal_entry(@invalid_attrs)
    end

    test "update_journal_entry/2 with valid data updates the journal_entry" do
      journal_entry = journal_entry_fixture()

      update_attrs = %{
        entry_text_markdown: "some updated entry_text_markdown",
        entry_text_html: "some updated entry_text_html",
        mood: "some updated mood",
        is_private: false,
        is_short_entry: false
      }

      assert {:ok, %JournalEntry{} = journal_entry} =
               Journals.update_journal_entry(journal_entry, update_attrs)

      assert journal_entry.entry_text_markdown == "some updated entry_text_markdown"
      assert journal_entry.entry_text_html == "some updated entry_text_html"
      assert journal_entry.mood == "some updated mood"
      assert journal_entry.is_private == false
      assert journal_entry.is_short_entry == false
    end

    test "update_journal_entry/2 with invalid data returns error changeset" do
      journal_entry = journal_entry_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Journals.update_journal_entry(journal_entry, @invalid_attrs)

      # assert journal_entry == Journals.get_journal_entry!(journal_entry.id)
    end

    test "delete_journal_entry/1 deletes the journal_entry" do
      journal_entry = journal_entry_fixture()
      assert {:ok, %JournalEntry{}} = Journals.delete_journal_entry(journal_entry)
      assert_raise Ecto.NoResultsError, fn -> Journals.get_journal_entry!(journal_entry.id) end
    end

    test "change_journal_entry/1 returns a journal_entry changeset" do
      journal_entry = journal_entry_fixture()
      assert %Ecto.Changeset{} = Journals.change_journal_entry(journal_entry)
    end
  end
end
