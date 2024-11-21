defmodule KlepsidraWeb.DocumentTypeLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.DocumentsFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    default_validity_period_unit: "year",
    default_validity_duration: 10,
    notification_lead_time_days: 30,
    processing_time_estimate_days: 30,
    default_buffer_time_days: 14
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    default_validity_period_unit: "month",
    default_validity_duration: 36,
    notification_lead_time_days: 60,
    processing_time_estimate_days: 45,
    default_buffer_time_days: 28
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    default_validity_period_unit: nil,
    default_validity_duration: nil,
    notification_lead_time_days: nil,
    processing_time_estimate_days: nil,
    default_buffer_time_days: nil
  }

  defp create_document_type(_) do
    document_type = document_type_fixture()
    %{document_type: document_type}
  end

  describe "Index" do
    setup [:create_document_type]

    test "lists all document_types", %{conn: conn, document_type: document_type} do
      {:ok, _index_live, html} = live(conn, ~p"/document_types")

      assert html =~ "Document types"
      # assert html =~ document_type.id
    end

    test "saves new document_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/document_types")

      assert index_live |> element("a", "New document type") |> render_click() =~
               "New document type"

      assert_patch(index_live, ~p"/document_types/new")

      assert index_live
             |> form("#document_type-form", document_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document_type-form", document_type: @create_attrs)
             |> render_submit()

      # assert_patch(index_live, ~p"/document_types")

      html = render(index_live)
      # assert html =~ "Document type created successfully"
      # assert html =~ "some id"
    end

    test "updates document_type in listing", %{conn: conn, document_type: document_type} do
      {:ok, index_live, _html} = live(conn, ~p"/document_types")

      assert index_live
             |> element("#document_types-#{document_type.id} a", "Edit")
             |> render_click() =~
               "Edit document type"

      assert_patch(index_live, ~p"/document_types/#{document_type}/edit")

      assert index_live
             |> form("#document_type-form", document_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document_type-form", document_type: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/document_types")

      html = render(index_live)
      assert html =~ "Document type updated successfully"
      # assert html =~ "some updated id"
    end

    test "deletes document_type in listing", %{conn: conn, document_type: document_type} do
      {:ok, index_live, _html} = live(conn, ~p"/document_types")

      assert index_live
             |> element("#document_types-#{document_type.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#document_types-#{document_type.id}")
    end
  end

  describe "Show" do
    setup [:create_document_type]

    test "displays document_type", %{conn: conn, document_type: document_type} do
      {:ok, _show_live, html} = live(conn, ~p"/document_types/#{document_type}")

      assert html =~ "Show document type"
    end

    test "updates document_type within modal", %{conn: conn, document_type: document_type} do
      {:ok, show_live, _html} = live(conn, ~p"/document_types/#{document_type}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit document type"

      assert_patch(show_live, ~p"/document_types/#{document_type}/show/edit")

      assert show_live
             |> form("#document_type-form", document_type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#document_type-form", document_type: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/document_types/#{document_type}")

      html = render(show_live)
      assert html =~ "Document type updated successfully"
    end
  end
end
