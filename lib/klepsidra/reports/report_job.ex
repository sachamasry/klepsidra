defmodule Klepsidra.Reports.ReportJob do
  @moduledoc """
  Defines a schema for the `ReportJob` entity, a queue and audit trail of all
  jobs, requesting the generation of a report.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID,
          report_name: String.t(),
          report_version: integer(),
          report_template: String.t(),
          output_format: String.t(),
          state: String.t(),
          parameter_fingerprint: String.t(),
          parameters_and_data: map(),
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
    field :report_name, :string
    field :report_version, :integer, default: 1
    field :report_template, :string
    field :output_format, :string, default: "pdf"
    field :state, :string
    field :parameter_fingerprint, :string
    field :parameters_and_data, :map
    field :errors, :map
    field :meta, :map
    field :attempt, :integer, default: 1
    field :max_attempts, :integer, default: 3
    field :priority, :integer, default: 0
    field :result_path, :string
    field :generation_time_ms, :integer, default: 0
    field :scheduled_at, :utc_datetime, default: DateTime.utc_now() |> DateTime.truncate(:second)
    field :attempted_at, :utc_datetime
    field :attempted_by, :map
    field :cancelled_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :discarded_at, :utc_datetime

    field :cache_expires_at, :utc_datetime,
      default: DateTime.utc_now() |> DateTime.add(7, :day) |> DateTime.truncate(:second)

    field :cache_hits, :integer, default: 0
    field :cache_is_valid, :boolean, default: true
    field :cache_invalidation_reason, :map
    field :cache_last_accessed_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(report_job, attrs) do
    report_job
    |> cast(attrs, [
      :report_name,
      :report_version,
      :report_template,
      :output_format,
      :state,
      :parameter_fingerprint,
      :parameters_and_data,
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
      :report_template,
      :output_format,
      :parameter_fingerprint,
      :parameters_and_data
    ])
  end
end
