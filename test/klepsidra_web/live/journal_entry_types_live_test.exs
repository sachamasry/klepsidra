defmodule KlepsidraWeb.JournalEntryTypesLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.JournalsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  defp create_journal_entry_types(_) do
    journal_entry_types = journal_entry_types_fixture()
    %{journal_entry_types: journal_entry_types}
  end

  describe "Index" do
    setup [:create_journal_entry_types]

    test "lists all journal_entry_types", %{conn: conn, journal_entry_types: journal_entry_types} do
      {:ok, _index_live, html} = live(conn, ~p"/journal_entry_types")

      assert html =~ "Journal entry types"
      assert html =~ journal_entry_types.name
    end

    test "saves new journal_entry_types", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/journal_entry_types")

      assert index_live |> element("a", "New journal entry type") |> render_click() =~
               "New journal entry type"

      assert_patch(index_live, ~p"/journal_entry_types/new")

      # assert index_live
      #        |> form("#journal_entry_types-form", journal_entry_types: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      # assert index_live
      #        |> form("#journal_entry_types-form", journal_entry_types: @create_attrs)
      #        |> render_submit()

      # assert_patch(index_live, ~p"/journal_entry_types")

      # html = render(index_live)
      # assert html =~ "Journal entry types created successfully"
      # assert html =~ "some name"
    end

    # test "updates journal_entry_types in listing", %{conn: conn, journal_entry_types: journal_entry_types} do
    #   {:ok, index_live, _html} = live(conn, ~p"/journal_entry_types")

    # assert index_live |> element("#journal_entry_types-#{journal_entry_types.id} a", "Edit") |> render_click() =~
    "Edit Journal entry types"

    # assert_patch(index_live, ~p"/journal_entry_types/#{journal_entry_types}/edit")

    # assert index_live
    #        |> form("#journal_entry_types-form", journal_entry_types: @invalid_attrs)
    #        |> render_change() =~ "can&#39;t be blank"

    # assert index_live
    #        |> form("#journal_entry_types-form", journal_entry_types: @update_attrs)
    #        |> render_submit()

    # assert_patch(index_live, ~p"/journal_entry_types")

    # html = render(index_live)
    # assert html =~ "Journal entry types updated successfully"
    # assert html =~ "some updated name"
    # end

    # test "deletes journal_entry_types in listing", %{conn: conn, journal_entry_types: journal_entry_types} do
    #   {:ok, index_live, _html} = live(conn, ~p"/journal_entry_types")

    #   assert index_live |> element("#journal_entry_types-#{journal_entry_types.id} a", "Delete") |> render_click()
    #   refute has_element?(index_live, "#journal_entry_types-#{journal_entry_types.id}")
    # end
  end

  describe "Show" do
    setup [:create_journal_entry_types]

    test "displays journal_entry_types", %{conn: conn, journal_entry_types: journal_entry_types} do
      {:ok, _show_live, html} = live(conn, ~p"/journal_entry_types/#{journal_entry_types}")

      assert html =~ "Show journal entry type"
      assert html =~ journal_entry_types.name
    end

    test "updates journal_entry_types within modal", %{
      conn: conn,
      journal_entry_types: journal_entry_types
    } do
      {:ok, show_live, _html} = live(conn, ~p"/journal_entry_types/#{journal_entry_types}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit journal entry type"

      assert_patch(show_live, ~p"/journal_entry_types/#{journal_entry_types}/show/edit")

      # assert show_live
      #        |> form("#journal_entry_types-form", journal_entry_types: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      # assert show_live
      #        |> form("#journal_entry_types-form", journal_entry_types: @update_attrs)
      #        |> render_submit()

      # assert_patch(show_live, ~p"/journal_entry_types/#{journal_entry_types}")

      # html = render(show_live)
      # assert html =~ "Journal entry types updated successfully"
      # assert html =~ "some updated name"
    end
  end
end
