defmodule KlepsidraWeb.DocumentIssuerLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.DocumentsFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    country_id: nil,
    contact_information: %{},
    website_url: "some website_url"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    country_id: nil,
    contact_information: %{},
    website_url: "some updated website_url"
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    country_id: nil,
    contact_information: nil,
    website_url: nil
  }

  defp create_document_issuer(_) do
    document_issuer = document_issuer_fixture()
    %{document_issuer: document_issuer}
  end

  describe "Index" do
    setup [:create_document_issuer]

    test "lists all document_issuers", %{conn: conn, document_issuer: document_issuer} do
      {:ok, _index_live, html} = live(conn, ~p"/document_issuers")

      assert html =~ "Document issuers"
      assert html =~ document_issuer.name
    end

    test "saves new document_issuer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/document_issuers")

      assert index_live |> element("a", "New document issuer") |> render_click() =~
               "New document issuer"

      assert_patch(index_live, ~p"/document_issuers/new")

      assert index_live
             |> form("#document_issuer-form", document_issuer: @invalid_attrs)

      # |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document_issuer-form", document_issuer: @create_attrs)
             |> render_submit()

      # assert_patch(index_live, ~p"/document_issuers")

      html = render(index_live)
      # assert html =~ "Document issuer created successfully"
      assert html =~ "some name"
    end

    test "updates document_issuer in listing", %{conn: conn, document_issuer: document_issuer} do
      {:ok, index_live, _html} = live(conn, ~p"/document_issuers")

      assert index_live
             |> element("#document_issuers-#{document_issuer.id} a", "Edit")
             |> render_click() =~
               "Edit document issuer"

      assert_patch(index_live, ~p"/document_issuers/#{document_issuer}/edit")

      assert index_live
             |> form("#document_issuer-form", document_issuer: @invalid_attrs)

      # |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document_issuer-form", document_issuer: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/document_issuers")

      html = render(index_live)
      assert html =~ "Document issuer updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes document_issuer in listing", %{conn: conn, document_issuer: document_issuer} do
      {:ok, index_live, _html} = live(conn, ~p"/document_issuers")

      assert index_live
             |> element("#document_issuers-#{document_issuer.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#document_issuers-#{document_issuer.id}")
    end
  end

  describe "Show" do
    setup [:create_document_issuer]

    test "displays document_issuer", %{conn: conn, document_issuer: document_issuer} do
      {:ok, _show_live, html} = live(conn, ~p"/document_issuers/#{document_issuer}")

      assert html =~ "Show Document issuer"
      assert html =~ document_issuer.name
    end

    test "updates document_issuer within modal", %{conn: conn, document_issuer: document_issuer} do
      {:ok, show_live, _html} = live(conn, ~p"/document_issuers/#{document_issuer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Document issuer"

      assert_patch(show_live, ~p"/document_issuers/#{document_issuer}/show/edit")

      assert show_live
             |> form("#document_issuer-form", document_issuer: @invalid_attrs)

      # |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#document_issuer-form", document_issuer: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/document_issuers/#{document_issuer}")

      html = render(show_live)
      assert html =~ "Document issuer updated successfully"
      assert html =~ "some updated name"
    end
  end
end
