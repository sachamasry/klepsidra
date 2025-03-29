defmodule Klepsidra.ReportsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Reports` context.
  """

  @doc """
  Generate a report.
  """
  def report_fixture(attrs \\ %{}) do
    {:ok, report} =
      attrs
      |> Enum.into(%{
        report_name: "Client timesheet",
        system_report_name: "client_timesheet",
        report_template_name: "Default",
        description: "Report of all activities carried out for a client",
        template_path: "/tmp/client_timesheet.jrxml",
        output_type: :pdf,
        output_filename_template: "client_timesheet-{date}"
      })
      |> Klepsidra.Reports.create_report()

    report
  end
end
