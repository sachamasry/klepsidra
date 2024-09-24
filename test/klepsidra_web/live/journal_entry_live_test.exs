defmodule KlepsidraWeb.JournalEntryLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.JournalsFixtures

  @create_attrs %{
    entry_text_markdown: "some entry_text_markdown",
    entry_text_html: "some entry_text_html",
    mood: "some mood",
    is_private: true,
    is_short_entry: true
  }
  @update_attrs %{
    entry_text_markdown: "some updated entry_text_markdown",
    entry_text_html: "some updated entry_text_html",
    mood: "some updated mood",
    is_private: false,
    is_short_entry: false
  }
  @invalid_attrs %{
    entry_text_markdown: nil,
    entry_text_html: nil,
    mood: nil,
    is_private: false,
    is_short_entry: false
  }

  defp create_journal_entry(_) do
    journal_entry = journal_entry_fixture()
    %{journal_entry: journal_entry}
  end

  describe "Index" do
    setup [:create_journal_entry]

    test "lists all journal_entries", %{conn: conn, journal_entry: journal_entry} do
      {:ok, _index_live, html} = live(conn, ~p"/journal_entries")

      assert html =~ "Listing Journal entries"
      assert html =~ journal_entry.entry_text_markdown
    end

    test "saves new journal_entry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/journal_entries")

      assert index_live |> element("a", "New Journal entry") |> render_click() =~
               "New Journal entry"

      assert_patch(index_live, ~p"/journal_entries/new")

      assert index_live
             |> form("#journal_entry-form", journal_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#journal_entry-form", journal_entry: @create_attrs)
             |> render_submit()

      # assert_patch(index_live, ~p"/journal_entries")

      html = render(index_live)
      # assert html =~ "Journal entry created successfully"
      assert html =~ "some entry_text_markdown"
    end

    test "updates journal_entry in listing", %{conn: conn, journal_entry: journal_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/journal_entries")

      assert index_live
             |> element("#journal_entries-#{journal_entry.id} a", "Edit")
             |> render_click() =~
               "Edit Journal entry"

      assert_patch(index_live, ~p"/journal_entries/#{journal_entry}/edit")

      assert index_live
             |> form("#journal_entry-form", journal_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#journal_entry-form", journal_entry: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/journal_entries")

      html = render(index_live)
      assert html =~ "Journal entry updated successfully"
      assert html =~ "some updated entry_text_markdown"
    end

    test "deletes journal_entry in listing", %{conn: conn, journal_entry: journal_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/journal_entries")

      assert index_live
             |> element("#journal_entries-#{journal_entry.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#journal_entries-#{journal_entry.id}")
    end
  end

  describe "Show" do
    setup [:create_journal_entry]

    test "displays journal_entry", %{conn: conn, journal_entry: journal_entry} do
      {:ok, _show_live, html} = live(conn, ~p"/journal_entries/#{journal_entry}")

      assert html =~ "Show Journal entry"
      assert html =~ journal_entry.entry_text_markdown
    end

    test "updates journal_entry within modal", %{conn: conn, journal_entry: journal_entry} do
      {:ok, show_live, _html} = live(conn, ~p"/journal_entries/#{journal_entry}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Journal entry"

      assert_patch(show_live, ~p"/journal_entries/#{journal_entry}/show/edit")

      assert show_live
             |> form("#journal_entry-form", journal_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#journal_entry-form", journal_entry: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/journal_entries/#{journal_entry}")

      html = render(show_live)
      assert html =~ "Journal entry updated successfully"
      assert html =~ "some updated entry_text_markdown"
    end
  end
end
