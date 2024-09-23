defmodule Klepsidra.TimeTracking.TimerTest do
  use ExUnit.Case, async: true
  import Klepsidra.TimeTracking.Timer

  describe "Timers" do
    test "test removal of restricted units from decomposed unit" do
      assert adjust_for_restricted_subunits(
               (24 * 60 * 60 + 1.75 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment, :minute_increment]),
               [:day, :hour_increment, :minute_increment]
             ) == nil

      assert adjust_for_restricted_subunits(
               (24 * 60 * 60 + 1.75 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment, :minute_increment]),
               [:day, :hour_increment]
             ) == [
               Cldr.Unit.new!(:day, 1),
               Cldr.Unit.new!(:hour_increment, 1),
               Cldr.Unit.new!(:minute_increment, "45.0000000000000480")
             ]

      assert adjust_for_restricted_subunits(
               (23 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment]),
               [:hour_increment]
             ) == nil

      assert adjust_for_restricted_subunits(
               (23 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment]),
               [:day, :hour_increment]
             ) == nil

      assert adjust_for_restricted_subunits(
               (23 * 60 * 60)
               |> Cldr.Unit.new!(:second)
               |> Cldr.Unit.decompose([:day, :hour_increment]),
               [:hour_increment, :minute_increment]
             ) == nil
    end

    test "returns truthy or falsy answer to whether provided list is empty" do
      assert non_empty_list?([], nil) == nil
      assert non_empty_list?([Cldr.Unit.new!(:day, 1)], []) == [Cldr.Unit.new!(:day, 1)]
      assert non_empty_list?([0, 1, 2], []) == [0, 1, 2]
    end
  end

  describe "Test date and time formatting functions" do
    test "returns human-readable date from valid NaiveDateTime" do
      assert format_human_readable_date(~N[2024-01-01T12:34:56]) ==
               {:ok, "Monday, 1 Jan 2024"}
    end

    test "returns human-readable time from valid NaiveDateTime" do
      assert format_human_readable_time(~N[2024-01-01T12:34:56]) == {:ok, "12:34"}

      assert format_human_readable_time(~N[2024-01-01T12:34:56], "{h12}:{m} {am}") ==
               {:ok, "12:34 pm"}

      assert format_human_readable_time(~N[2024-01-01T11:34:56], "{h12}:{m} {am}") ==
               {:ok, "11:34 am"}

      assert format_human_readable_time!(~N[2024-01-01T12:34:56]) == "12:34"

      assert format_human_readable_time!(~N[2024-01-01T12:34:56], "{h12}:{m} {am}") ==
               "12:34 pm"

      assert format_human_readable_time!(~N[2024-01-01T11:34:56], "{h12}:{m} {am}") ==
               "11:34 am"

      assert_raise Timex.Format.FormatError, "Format string cannot be empty.", fn ->
        format_human_readable_time!(~N[2024-01-01T11:34:56], "")
      end

      # Test with illegal datetime argument
      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time("")
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!("")
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(nil)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(nil)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(false)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(false)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time([])
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!([])
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(%{})
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(%{})
                   end

      # Test with empty format_string
      assert format_human_readable_time(~N[2024-01-01T11:34:56], "xyz") ==
               {:error, {:format, "Invalid format string, must contain at least one directive."}}

      assert_raise Timex.Format.FormatError,
                   "Invalid format string, must contain at least one directive.",
                   fn ->
                     format_human_readable_time!(~N[2024-01-01T11:34:56], "xyz")
                   end

      # Test with nil format_string
      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(~N[2024-01-01T11:34:56], nil)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(~N[2024-01-01T11:34:56], nil)
                   end

      # Test with atom format_string
      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(~N[2024-01-01T11:34:56], false)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(~N[2024-01-01T11:34:56], :atom)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(~N[2024-01-01T11:34:56], false)
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(~N[2024-01-01T11:34:56], :atom)
                   end

      # Test with list format_string
      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time(~N[2024-01-01T11:34:56], [])
                   end

      assert_raise FunctionClauseError,
                   fn ->
                     format_human_readable_time!(~N[2024-01-01T11:34:56], [])
                   end
    end
  end
end
