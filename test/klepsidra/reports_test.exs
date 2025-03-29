defmodule Klepsidra.ReportsTest do
  use Klepsidra.DataCase

  alias Klepsidra.Reports

  describe "reports" do
    alias Klepsidra.Reports.Report

    import Klepsidra.ReportsFixtures

    @invalid_attrs %{
      report_name: nil,
      system_report_name: nil,
      report_template_name: nil,
      description: nil,
      template_path: nil,
      output_type: nil,
      output_filename_template: nil
    }

    test "list_reports/0 returns all reports" do
      report = report_fixture()
      assert Reports.list_reports() == [report]
    end

    test "get_report!/1 returns the report with given id" do
      report = report_fixture()
      assert Reports.get_report!(report.id) == report
    end

    test "create_report/1 with valid data creates a report" do
      valid_attrs = %{
        report_name: "Test report",
        system_report_name: "test_report_name",
        report_template_name: "Default",
        description: "Test report description",
        template_path: "/tmp/test_report.jrxml",
        output_type: :pdf,
        output_filename_template: "test_report-{date}"
      }

      assert {:ok, %Report{} = report} = Reports.create_report(valid_attrs)
      assert report.report_name == "Test report"
      assert report.system_report_name == "test_report_name"
      assert report.report_template_name == "Default"
      assert report.description == "Test report description"
      assert report.template_path == "/tmp/test_report.jrxml"
      assert report.output_type == :pdf
      assert report.output_filename_template == "test_report-{date}"
    end

    test "create_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reports.create_report(@invalid_attrs)
    end

    test "update_report/2 with valid data updates the report" do
      report = report_fixture()

      update_attrs = %{
        report_name: "Test report (HTML)",
        system_report_name: "test_report_name",
        report_template_name: "Default",
        description: "HTML Test report description",
        template_path: "/tmp/test_report-html.jrxml",
        output_type: :html,
        output_filename_template: "html_test_report-{date}"
      }

      assert {:ok, %Report{} = report} = Reports.update_report(report, update_attrs)
      assert report.report_name == "Test report (HTML)"
      assert report.system_report_name == "test_report_name"
      assert report.report_template_name == "Default"
      assert report.description == "HTML Test report description"
      assert report.template_path == "/tmp/test_report-html.jrxml"
      assert report.output_type == :html
      assert report.output_filename_template == "html_test_report-{date}"
    end

    test "update_report/2 with invalid data returns error changeset" do
      report = report_fixture()
      assert {:error, %Ecto.Changeset{}} = Reports.update_report(report, @invalid_attrs)
      assert report == Reports.get_report!(report.id)
    end

    test "delete_report/1 deletes the report" do
      report = report_fixture()
      assert {:ok, %Report{}} = Reports.delete_report(report)
      assert_raise Ecto.NoResultsError, fn -> Reports.get_report!(report.id) end
    end

    test "change_report/1 returns a report changeset" do
      report = report_fixture()
      assert %Ecto.Changeset{} = Reports.change_report(report)
    end
  end
end
