defmodule KlepsidraWeb.TripLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.TravelFixtures

  @create_attrs %{
    user_id: "7488a646-e31f-11e4-aace-600308960662",
    country_id: "some country_id",
    description: "Business trip",
    entry_date: "2024-11-29",
    exit_date: "2024-11-29"
  }
  @update_attrs %{
    user_id: "7488a646-e31f-11e4-aace-600308960668",
    country_id: "some updated country_id",
    description: "Leisure trip",
    entry_date: "2024-11-30",
    exit_date: "2024-11-30"
  }
  @invalid_attrs %{
    user_id: nil,
    country_id: nil,
    description: "",
    entry_date: nil,
    exit_date: nil
  }

  # defp create_trip(_) do
  #   trip = trip_fixture()
  #   %{trip: trip}
  # end

  # describe "Index" do
  #   setup [:create_trip]

  #   test "lists all trips", %{conn: conn, trip: trip} do
  #     {:ok, _index_live, html} = live(conn, ~p"/trips")

  #     assert html =~ "Listing Trips"
  #     assert html =~ trip.country_id
  #   end

  #   test "saves new trip", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/trips")

  #     assert index_live |> element("a", "New Trip") |> render_click() =~
  #              "New Trip"

  #     assert_patch(index_live, ~p"/trips/new")

  #     assert index_live
  #            |> form("#trip-form", trip: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert index_live
  #            |> form("#trip-form", trip: @create_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/trips")

  #     html = render(index_live)
  #     assert html =~ "Trip created successfully"
  #     assert html =~ "some country_id"
  #   end

  #   test "updates trip in listing", %{conn: conn, trip: trip} do
  #     {:ok, index_live, _html} = live(conn, ~p"/trips")

  #     assert index_live |> element("#trips-#{trip.id} a", "Edit") |> render_click() =~
  #              "Edit Trip"

  #     assert_patch(index_live, ~p"/trips/#{trip}/edit")

  #     assert index_live
  #            |> form("#trip-form", trip: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert index_live
  #            |> form("#trip-form", trip: @update_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/trips")

  #     html = render(index_live)
  #     assert html =~ "Trip updated successfully"
  #     assert html =~ "some updated country_id"
  #   end

  #   test "deletes trip in listing", %{conn: conn, trip: trip} do
  #     {:ok, index_live, _html} = live(conn, ~p"/trips")

  #     assert index_live |> element("#trips-#{trip.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#trips-#{trip.id}")
  #   end
  # end

  # describe "Show" do
  #   setup [:create_trip]

  #   test "displays trip", %{conn: conn, trip: trip} do
  #     {:ok, _show_live, html} = live(conn, ~p"/trips/#{trip}")

  #     assert html =~ "Show Trip"
  #     assert html =~ trip.country_id
  #   end

  #   test "updates trip within modal", %{conn: conn, trip: trip} do
  #     {:ok, show_live, _html} = live(conn, ~p"/trips/#{trip}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Trip"

  #     assert_patch(show_live, ~p"/trips/#{trip}/show/edit")

  #     assert show_live
  #            |> form("#trip-form", trip: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert show_live
  #            |> form("#trip-form", trip: @update_attrs)
  #            |> render_submit()

  #     assert_patch(show_live, ~p"/trips/#{trip}")

  #     html = render(show_live)
  #     assert html =~ "Trip updated successfully"
  #     assert html =~ "some updated country_id"
  #   end
  # end
end
