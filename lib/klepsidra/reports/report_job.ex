defmodule Klepsidra.Reports.ReportJob do
  @moduledoc """
  Defines a schema for the `ReportJob` entity, a queue and audit trail of all
  jobs, requesting the generation of a report.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Klepsidra.Reports
  alias Klepsidra.Reports.Report
  alias Klepsidra.ReportJobs
  alias Klepsidra.Reporting.ReportTableManager
  alias Klepsidra.Utilities.HashFunctions

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID,
          state: String.t(),
          report_name: String.t(),
          system_report_name: String.t(),
          template_variant_name: String.t(),
          system_template_name: String.t(),
          report_version: integer(),
          template_path: String.t(),
          parameter_fingerprint: String.t(),
          parameters_and_data: map(),
          temporary_tables_created: map(),
          output_path: String.t(),
          output_filename: String.t(),
          output_type: atom(),
          errors: map(),
          meta: map(),
          attempt: integer(),
          max_attempts: integer(),
          priority: integer(),
          result_path: String.t(),
          generation_time_ms: integer(),
          scheduled_at: DateTime.t(),
          attempted_at: DateTime.t(),
          attempted_by: map(),
          cancelled_at: DateTime.t(),
          completed_at: DateTime.t(),
          discarded_at: DateTime.t(),
          cache_expires_at: DateTime.t(),
          cache_hits: integer(),
          cache_is_valid: boolean(),
          cache_invalidation_reason: map(),
          cache_last_accessed_at: DateTime.t()
        }
  schema "report_jobs" do
    field :state, Ecto.Enum,
      values: [:scheduled, :available, :executing, :retryable, :completed, :discarded, :cancelled],
      default: :available

    field :report_name, :string
    field :system_report_name, :string
    field :template_variant_name, :string
    field :system_template_name, :string
    field :report_version, :integer, default: 1
    field :template_path, :string

    field :parameter_fingerprint, :string
    field :parameters_and_data, :map
    field :temporary_tables_created, :map
    field :output_path, :string
    field :output_filename, :string

    field :output_type, Ecto.Enum,
      values: [:pdf, :html, :rtf, :txt, :csv, :json, :xlsx, :docx, :pptx, :odt, :ods]

    field :errors, :map
    field :meta, :map
    field :attempt, :integer, default: 1
    field :max_attempts, :integer, default: 3
    field :priority, :integer, default: 0
    field :result_path, :string
    field :generation_time_ms, :integer, default: 0
    field :scheduled_at, :utc_datetime, default: DateTime.utc_now() |> DateTime.truncate(:second)
    # :utc_datetime
    field :attempted_at, :string
    field :attempted_by, :map
    # :utc_datetime
    field :cancelled_at, :string
    # :utc_datetime
    field :completed_at, :string
    # :utc_datetime
    field :discarded_at, :string
    # :utc_datetime
    field :cache_expires_at, :string
    field :cache_hits, :integer, default: 0
    field :cache_is_valid, :boolean, default: true
    field :cache_invalidation_reason, :map
    # :utc_datetime
    field :cache_last_accessed_at, :string

    timestamps()
  end

  @doc false
  def changeset(report_job, attrs) do
    report_job
    |> cast(attrs, [
      :state,
      :report_name,
      :system_report_name,
      :template_variant_name,
      :system_template_name,
      :report_version,
      :template_path,
      :parameter_fingerprint,
      :parameters_and_data,
      :temporary_tables_created,
      :output_path,
      :output_filename,
      :output_type,
      :errors,
      :meta,
      :attempt,
      :max_attempts,
      :priority,
      :result_path,
      :generation_time_ms,
      :scheduled_at,
      :attempted_at,
      :attempted_by,
      :cancelled_at,
      :completed_at,
      :discarded_at,
      :cache_expires_at,
      :cache_hits,
      :cache_is_valid,
      :cache_invalidation_reason,
      :cache_last_accessed_at
    ])
    |> validate_required([
      :report_name,
      :system_report_name,
      :template_variant_name,
      :system_template_name,
      :output_type,
      :parameter_fingerprint,
      :parameters_and_data
    ])
  end

  def queue_report_job(
        system_report_name,
        system_template_name,
        parameters,
        dataset,
        _options \\ []
      )
      when is_bitstring(system_report_name) and is_bitstring(system_template_name) and
             is_map(parameters) and
             is_list(dataset) do
    unique_job_id = Ecto.UUID.generate()

    primary_table_name =
      ReportTableManager.construct_table_name(unique_job_id, system_report_name)

    ReportTableManager.create_temporary_table(primary_table_name, dataset)

    temporary_tables_created = %{primary: primary_table_name}

    parameters_and_data = %{parameters: parameters}
    parameter_fingerprint = HashFunctions.compute_hash(parameters_and_data)

    %Report{
      report_name: report_name,
      template_variant_name: template_variant_name,
      system_template_name: system_template_name,
      template_path: template_path,
      output_type: output_type,
      output_filename_template: output_filename_template
    } = Reports.get_report_by_system_report_name(system_report_name)

    report_job_params =
      %{
        report_name: report_name,
        system_report_name: system_report_name,
        template_variant_name: template_variant_name,
        system_template_name: system_template_name,
        template_path: template_path,
        parameter_fingerprint: parameter_fingerprint,
        parameters_and_data: parameters_and_data,
        temporary_tables_created: temporary_tables_created,
        output_path: "output",
        output_filename: output_filename_template,
        output_type: output_type
      }

    case ReportJobs.create_report_job(report_job_params) do
      {:ok, report_job} ->
        report_job

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset
    end
  end
end
