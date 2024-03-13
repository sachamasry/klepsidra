defmodule KlepsidraWeb.TimerLiveTest do
  use KlepsidraWeb.ConnCase

  import Phoenix.LiveViewTest
  import Klepsidra.TimeTrackingFixtures

  @create_attrs %{description: "some description", start_stamp: "some start_stamp", end_stamp: "some end_stamp", duration: 42, duration_time_unit: "some duration_time_unit", reported_duration: 42, reported_duration_time_unit: "some reported_duration_time_unit"}
  @update_attrs %{description: "some updated description", start_stamp: "some updated start_stamp", end_stamp: "some updated end_stamp", duration: 43, duration_time_unit: "some updated duration_time_unit", reported_duration: 43, reported_duration_time_unit: "some updated reported_duration_time_unit"}
  @invalid_attrs %{description: nil, start_stamp: nil, end_stamp: nil, duration: nil, duration_time_unit: nil, reported_duration: nil, reported_duration_time_unit: nil}

  defp create_timer(_) do
    timer = timer_fixture()
    %{timer: timer}
  end

  describe "Index" do
    setup [:create_timer]

    test "lists all timers", %{conn: conn, timer: timer} do
      {:ok, _index_live, html} = live(conn, ~p"/timers")

      assert html =~ "Listing Timers"
      assert html =~ timer.description
    end

    test "saves new timer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/timers")

      assert index_live |> element("a", "New Timer") |> render_click() =~
               "New Timer"

      assert_patch(index_live, ~p"/timers/new")

      assert index_live
             |> form("#timer-form", timer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#timer-form", timer: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/timers")

      html = render(index_live)
      assert html =~ "Timer created successfully"
      assert html =~ "some description"
    end

    test "updates timer in listing", %{conn: conn, timer: timer} do
      {:ok, index_live, _html} = live(conn, ~p"/timers")

      assert index_live |> element("#timers-#{timer.id} a", "Edit") |> render_click() =~
               "Edit Timer"

      assert_patch(index_live, ~p"/timers/#{timer}/edit")

      assert index_live
             |> form("#timer-form", timer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#timer-form", timer: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/timers")

      html = render(index_live)
      assert html =~ "Timer updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes timer in listing", %{conn: conn, timer: timer} do
      {:ok, index_live, _html} = live(conn, ~p"/timers")

      assert index_live |> element("#timers-#{timer.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#timers-#{timer.id}")
    end
  end

  describe "Show" do
    setup [:create_timer]

    test "displays timer", %{conn: conn, timer: timer} do
      {:ok, _show_live, html} = live(conn, ~p"/timers/#{timer}")

      assert html =~ "Show Timer"
      assert html =~ timer.description
    end

    test "updates timer within modal", %{conn: conn, timer: timer} do
      {:ok, show_live, _html} = live(conn, ~p"/timers/#{timer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Timer"

      assert_patch(show_live, ~p"/timers/#{timer}/show/edit")

      assert show_live
             |> form("#timer-form", timer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#timer-form", timer: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/timers/#{timer}")

      html = render(show_live)
      assert html =~ "Timer updated successfully"
      assert html =~ "some updated description"
    end
  end
end
