defmodule Klepsidra.ReportJob do
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
          state: String.t(),
          report_fingerprint: String.t(),
          parameters: map(),
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
    field :output_format, :string
    field :state, :string
    field :report_fingerprint, :string
    field :parameters, :string  # Stored as JSON string
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
end
