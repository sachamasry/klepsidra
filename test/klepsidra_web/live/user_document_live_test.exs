defmodule KlepsidraWeb.UserDocumentLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.DocumentsFixtures

  @create_attrs %{id: "7488a646-e31f-11e4-aace-600308960662", document_type_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662", unique_reference: "some unique_reference", issued_by: "some issued_by", issuing_country_id: "some issuing_country_id", issue_date: "2024-11-19", expiry_date: "2024-11-19", is_active: true, file_url: "some file_url"}
  @update_attrs %{id: "7488a646-e31f-11e4-aace-600308960668", document_type_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668", unique_reference: "some updated unique_reference", issued_by: "some updated issued_by", issuing_country_id: "some updated issuing_country_id", issue_date: "2024-11-20", expiry_date: "2024-11-20", is_active: false, file_url: "some updated file_url"}
  @invalid_attrs %{id: nil, document_type_id: nil, user_id: nil, unique_reference: nil, issued_by: nil, issuing_country_id: nil, issue_date: nil, expiry_date: nil, is_active: false, file_url: nil}

  defp create_user_document(_) do
    user_document = user_document_fixture()
    %{user_document: user_document}
  end

  describe "Index" do
    setup [:create_user_document]

    test "lists all user_documents", %{conn: conn, user_document: user_document} do
      {:ok, _index_live, html} = live(conn, ~p"/user_documents")

      assert html =~ "Listing User documents"
      assert html =~ user_document.unique_reference
    end

    test "saves new user_document", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/user_documents")

      assert index_live |> element("a", "New User document") |> render_click() =~
               "New User document"

      assert_patch(index_live, ~p"/user_documents/new")

      assert index_live
             |> form("#user_document-form", user_document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_document-form", user_document: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/user_documents")

      html = render(index_live)
      assert html =~ "User document created successfully"
      assert html =~ "some unique_reference"
    end

    test "updates user_document in listing", %{conn: conn, user_document: user_document} do
      {:ok, index_live, _html} = live(conn, ~p"/user_documents")

      assert index_live |> element("#user_documents-#{user_document.id} a", "Edit") |> render_click() =~
               "Edit User document"

      assert_patch(index_live, ~p"/user_documents/#{user_document}/edit")

      assert index_live
             |> form("#user_document-form", user_document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_document-form", user_document: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/user_documents")

      html = render(index_live)
      assert html =~ "User document updated successfully"
      assert html =~ "some updated unique_reference"
    end

    test "deletes user_document in listing", %{conn: conn, user_document: user_document} do
      {:ok, index_live, _html} = live(conn, ~p"/user_documents")

      assert index_live |> element("#user_documents-#{user_document.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_documents-#{user_document.id}")
    end
  end

  describe "Show" do
    setup [:create_user_document]

    test "displays user_document", %{conn: conn, user_document: user_document} do
      {:ok, _show_live, html} = live(conn, ~p"/user_documents/#{user_document}")

      assert html =~ "Show User document"
      assert html =~ user_document.unique_reference
    end

    test "updates user_document within modal", %{conn: conn, user_document: user_document} do
      {:ok, show_live, _html} = live(conn, ~p"/user_documents/#{user_document}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User document"

      assert_patch(show_live, ~p"/user_documents/#{user_document}/show/edit")

      assert show_live
             |> form("#user_document-form", user_document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#user_document-form", user_document: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/user_documents/#{user_document}")

      html = render(show_live)
      assert html =~ "User document updated successfully"
      assert html =~ "some updated unique_reference"
    end
  end
end
