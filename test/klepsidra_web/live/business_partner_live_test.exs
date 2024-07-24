defmodule KlepsidraWeb.BusinessPartnerLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.BusinessPartnersFixtures

  @create_attrs %{
    name: "some name",
    description: "some description"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description"
  }
  @invalid_attrs %{name: nil, description: nil}

  defp create_business_partner(_) do
    business_partner = business_partner_fixture()
    %{business_partner: business_partner}
  end

  describe "Index" do
    setup [:create_business_partner]

    test "lists all business_partners", %{conn: conn, business_partner: business_partner} do
      {:ok, _index_live, html} = live(conn, ~p"/customers")

      assert html =~ "Customers"
      assert html =~ business_partner.name
    end

    test "saves new business_partner", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/customers")

      assert index_live |> element("a", "New customer") |> render_click() =~
               "New customer"

      # assert_patch(index_live, ~p"/customers/new")

      assert index_live
             |> form("#business_partner-form", business_partner: @invalid_attrs)
             |> render_change() =~ "Enter a customer name"

      assert index_live
             |> form("#business_partner-form", business_partner: @create_attrs)
             |> render_submit()

      # assert_patch(index_live, ~p"/customers")

      html = render(index_live)
      # assert html =~ "Business partner created successfully"
      assert html =~ "some name"
    end

    test "updates business_partner in listing", %{conn: conn, business_partner: business_partner} do
      {:ok, index_live, _html} = live(conn, ~p"/customers")

      assert index_live
             |> element("#business_partners-#{business_partner.id} a", "Edit")
             |> render_click() =~
               "Edit customer"

      assert_patch(index_live, ~p"/customers/#{business_partner}/edit")

      assert index_live
             |> form("#business_partner-form", business_partner: @invalid_attrs)
             |> render_change() =~ "Enter a customer name"

      assert index_live
             |> form("#business_partner-form", business_partner: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/customers")

      html = render(index_live)
      assert html =~ "Customer updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes business_partner in listing", %{conn: conn, business_partner: business_partner} do
      {:ok, index_live, _html} = live(conn, ~p"/customers")

      assert index_live
             |> element("#business_partners-#{business_partner.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#business_partners-#{business_partner.id}")
    end
  end

  describe "Show" do
    setup [:create_business_partner]

    test "displays business_partner", %{conn: conn, business_partner: business_partner} do
      {:ok, _show_live, html} = live(conn, ~p"/customers/#{business_partner}")

      assert html =~ "Show customer"
      assert html =~ business_partner.name
    end

    test "updates business_partner within modal", %{
      conn: conn,
      business_partner: business_partner
    } do
      {:ok, show_live, _html} = live(conn, ~p"/customers/#{business_partner}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit customer"

      assert_patch(show_live, ~p"/customers/#{business_partner}/show/edit")

      assert show_live
             |> form("#business_partner-form", business_partner: @invalid_attrs)
             |> render_change() =~ "Enter a customer name"

      assert show_live
             |> form("#business_partner-form", business_partner: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/customers/#{business_partner}")

      html = render(show_live)
      assert html =~ "Customer updated successfully"
      assert html =~ "some updated name"
    end
  end
end
