defmodule KlepsidraWeb.RelationshipTypeLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.KnowledgeManagementFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    is_predefined: true
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    is_predefined: false
  }
  @invalid_attrs %{name: nil, description: nil, is_predefined: false}

  defp create_relationship_type(_) do
    relationship_type = relationship_type_fixture()
    %{relationship_type: relationship_type}
  end

  describe "Index" do
    setup [:create_relationship_type]

    test "lists all knowledge_management_relationship_types", %{
      conn: conn,
      relationship_type: relationship_type
    } do
      {:ok, _index_live, html} = live(conn, ~p"/knowledge_management_relationship_types")

      assert html =~ "Listing Knowledge management relationship types"
      assert html =~ relationship_type.name
    end

    test "saves new relationship_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management_relationship_types")

      assert index_live |> element("a", "New Relationship type") |> render_click() =~
               "New Relationship type"

      assert_patch(index_live, ~p"/knowledge_management_relationship_types/new")

      assert index_live
             |> form("#relationship_type-form", relationship_type: @invalid_attrs)
             |> render_change() =~ "Enter the relationship type"

      assert index_live
             |> form("#relationship_type-form", relationship_type: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/knowledge_management_relationship_types")

      html = render(index_live)
      assert html =~ "Relationship type created successfully"
      assert html =~ "some name"
    end

    test "updates relationship_type in listing", %{
      conn: conn,
      relationship_type: relationship_type
    } do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management_relationship_types")

      assert index_live
             |> element(
               "#knowledge_management_relationship_types-#{relationship_type.id} a",
               "Edit"
             )
             |> render_click() =~
               "Edit Relationship type"

      assert_patch(
        index_live,
        ~p"/knowledge_management_relationship_types/#{relationship_type}/edit"
      )

      assert index_live
             |> form("#relationship_type-form", relationship_type: @invalid_attrs)
             |> render_change() =~ "Enter the relationship type"

      assert index_live
             |> form("#relationship_type-form", relationship_type: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/knowledge_management_relationship_types")

      html = render(index_live)
      assert html =~ "Relationship type updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes relationship_type in listing", %{
      conn: conn,
      relationship_type: relationship_type
    } do
      {:ok, index_live, _html} = live(conn, ~p"/knowledge_management_relationship_types")

      assert index_live
             |> element(
               "#knowledge_management_relationship_types-#{relationship_type.id} a",
               "Delete"
             )
             |> render_click()

      refute has_element?(
               index_live,
               "#knowledge_management_relationship_types-#{relationship_type.id}"
             )
    end
  end

  describe "Show" do
    setup [:create_relationship_type]

    test "displays relationship_type", %{conn: conn, relationship_type: relationship_type} do
      {:ok, _show_live, html} =
        live(conn, ~p"/knowledge_management_relationship_types/#{relationship_type}")

      assert html =~ "Show Relationship type"
      assert html =~ relationship_type.name
    end

    test "updates relationship_type within modal", %{
      conn: conn,
      relationship_type: relationship_type
    } do
      {:ok, show_live, _html} =
        live(conn, ~p"/knowledge_management_relationship_types/#{relationship_type}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Relationship type"

      assert_patch(
        show_live,
        ~p"/knowledge_management_relationship_types/#{relationship_type}/show/edit"
      )

      assert show_live
             |> form("#relationship_type-form", relationship_type: @invalid_attrs)
             |> render_change() =~ "Enter the relationship type"

      assert show_live
             |> form("#relationship_type-form", relationship_type: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/knowledge_management_relationship_types/#{relationship_type}")

      html = render(show_live)
      assert html =~ "Relationship type updated successfully"
      assert html =~ "some updated name"
    end
  end
end
