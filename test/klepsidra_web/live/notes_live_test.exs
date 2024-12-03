defmodule KlepsidraWeb.NotesLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.KnowledgeManagementFixtures

  @create_attrs %{
    title: "some title",
    content: "some content",
    content_format: :markdown,
    # rendered_content: "some rendered_content",
    # rendered_content_format: :html,
    summary: "some summary",
    status: :draft,
    review_date: "2024-12-02"
    # pinned: true
    # priority: 42
  }
  @update_attrs %{
    title: "some updated title",
    content: "some updated content",
    content_format: :"org-mode",
    # rendered_content: "some updated rendered_content",
    # rendered_content_format: :pdf,
    summary: "some updated summary",
    status: :fleeting,
    review_date: "2024-12-03"
    # pinned: false
    # priority: 43
  }
  @invalid_attrs %{
    title: nil,
    content: nil,
    content_format: nil,
    # rendered_content: nil,
    # rendered_content_format: nil,
    summary: nil,
    status: nil,
    review_date: nil
    # pinned: false
    # priority: nil
  }

  defp create_notes(_) do
    note = note_fixture()
    %{note: note}
  end

  describe "Index" do
    setup [:create_notes]

    test "lists all knowledge_management_notes", %{conn: conn, note: note} do
      {:ok, _index_live, html} = live(conn, ~p"/knowledge_management/notes")

      assert html =~ "Knowledge management notes"
      assert html =~ note.title
    end

    test "saves new notes", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management/notes")

      assert index_live |> element("a", "New note") |> render_click() =~
               "New note"

      assert_patch(index_live, ~p"/knowledge_management/notes/new")

      assert index_live
             |> form("#notes-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#notes-form", note: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/knowledge_management/notes")

      html = render(index_live)
      assert html =~ "Note created successfully"
      assert html =~ "some title"
    end

    test "updates notes in listing", %{conn: conn, note: note} do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management/notes")

      assert index_live
             |> element("#knowledge_management_notes-#{note.id} a", "Edit")
             |> render_click() =~
               "Edit note"

      assert_patch(index_live, ~p"/knowledge_management/notes/#{note}/edit")

      assert index_live
             |> form("#notes-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#notes-form", note: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/knowledge_management/notes")

      html = render(index_live)
      assert html =~ "Note updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes notes in listing", %{conn: conn, note: note} do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management/notes")

      assert index_live
             |> element("#knowledge_management_notes-#{note.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#knowledge_management_notes-#{note.id}")
    end
  end

  describe "Show" do
    setup [:create_notes]

    test "displays notes", %{conn: conn, note: note} do
      {:ok, _show_live, html} = live(conn, ~p"/knowledge_management/notes/#{note}")

      assert html =~ "Show note"
      assert html =~ note.title
    end

    test "updates notes within modal", %{conn: conn, note: note} do
      {:ok, show_live, _html} = live(conn, ~p"/knowledge_management/notes/#{note}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit note"

      assert_patch(show_live, ~p"/knowledge_management/notes/#{note}/show/edit")

      assert show_live
             |> form("#notes-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#notes-form", note: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/knowledge_management/notes/#{note}")

      html = render(show_live)
      assert html =~ "Note updated successfully"
      assert html =~ "some updated title"
    end
  end
end
