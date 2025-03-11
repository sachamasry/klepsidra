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
          report_template: String.t(),
          output_format: String.t(),
          criteria_fingerprint: String.t(),
          state: String.t(),
          parameters: map(),
          dataset_fingerprint: String.t(),
          errors: map(),
          meta: map(),
          attempt: integer(),
          max_attempts: integer(),
          priority: integer(),
          result_path: String.t(),
          scheduled_at: String.t(),
          attempted_at: String.t(),
          attempted_by: map(),
          cancelled_at: String.t(),
          completed_at: String.t(),
          discarded_at: String.t()
        }
  schema "report_jobs" do
    field :report_name, :string
    field :report_template, :string
    field :output_format, :string, default: "pdf"
    field :criteria_fingerprint, :string
    field :state, :string
    # Stored as JSON string
    field :parameters, :string
    field :dataset_fingerprint, :string
    field :errors, :map
    field :meta, :map
    field :attempt, :integer
    field :max_attempts, :integer
    field :priority, :integer
    field :result_path, :string
    field :scheduled_at, :string
    field :attempted_at, :string
    field :attempted_by, :map
    field :cancelled_at, :string
    field :completed_at, :string
    field :discarded_at, :string

    timestamps()
  end

  @doc false
  def changeset(report_job, attrs) do
    report_job
    |> cast(attrs, [
      :report_name,
      :report_template,
      :output_format,
      :criteria_fingerprint,
      :state,
      :parameters,
      :dataset_fingerprint,
      :errors,
      :meta,
      :attempt,
      :max_attempts,
      :priority,
      :result_path,
      :scheduled_at,
      :attempted_at,
      :attempted_by,
      :cancelled_at,
      :completed_at,
      :discarded_at
    ])
    |> validate_required([
      :report_name,
      :report_template,
      :output_format,
      :criteria_fingerprint,
      :parameters,
      :dataset_fingerprint,
      :scheduled_at
    ])
  end
end
