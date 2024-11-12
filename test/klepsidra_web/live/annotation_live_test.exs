defmodule KlepsidraWeb.AnnotationLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.KnowledgeManagementFixtures

  @create_attrs %{
    entry_type: "annotation",
    text: "some text",
    author_name: "some author_name",
    comment: "some comment"
  }
  @update_attrs %{
    entry_type: "quote",
    text: "some updated text",
    author_name: "some updated author_name",
    comment: "some updated comment"
  }
  @invalid_attrs %{
    entry_type: "annotation",
    text: nil,
    author_name: nil,
    comment: nil
  }

  defp create_annotation(_) do
    annotation = annotation_fixture()
    %{annotation: annotation}
  end

  describe "Index" do
    setup [:create_annotation]

    test "lists all annotations", %{conn: conn, annotation: annotation} do
      {:ok, _index_live, html} = live(conn, ~p"/annotations")

      assert html =~ "Listing Annotations"
      assert html =~ annotation.id
    end

    test "saves new annotation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/annotations")

      assert index_live |> element("a", "New Annotation") |> render_click() =~
               "New Annotation"

      assert_patch(index_live, ~p"/annotations/new")

      assert index_live
             |> form("#annotation-form", annotation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#annotation-form", annotation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/annotations")

      html = render(index_live)
      assert html =~ "Annotation created successfully"
    end

    test "updates annotation in listing", %{conn: conn, annotation: annotation} do
      {:ok, index_live, _html} = live(conn, ~p"/annotations")

      assert index_live |> element("#annotations-#{annotation.id} a", "Edit") |> render_click() =~
               "Edit Annotation"

      assert_patch(index_live, ~p"/annotations/#{annotation}/edit")

      assert index_live
             |> form("#annotation-form", annotation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#annotation-form", annotation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/annotations")

      html = render(index_live)
      assert html =~ "Annotation updated successfully"
    end

    test "deletes annotation in listing", %{conn: conn, annotation: annotation} do
      {:ok, index_live, _html} = live(conn, ~p"/annotations")

      assert index_live |> element("#annotations-#{annotation.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#annotations-#{annotation.id}")
    end
  end

  describe "Show" do
    setup [:create_annotation]

    test "displays annotation", %{conn: conn, annotation: annotation} do
      {:ok, _show_live, html} = live(conn, ~p"/annotations/#{annotation}")

      assert html =~ "Show Annotation"
      assert html =~ annotation.id
    end

    test "updates annotation within modal", %{conn: conn, annotation: annotation} do
      {:ok, show_live, _html} = live(conn, ~p"/annotations/#{annotation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Annotation"

      assert_patch(show_live, ~p"/annotations/#{annotation}/show/edit")

      assert show_live
             |> form("#annotation-form", annotation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#annotation-form", annotation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/annotations/#{annotation}")

      html = render(show_live)
      assert html =~ "Annotation updated successfully"
    end
  end
end
