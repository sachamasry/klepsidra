defmodule Klepsidra.ReportJob do
  @moduledoc """
  """

  use Ecto.Schema

  schema "report_jobs" do
    field :status, :string
    field :report_fingerprint, :string
    field :parameters, :string  # Stored as JSON string
    field :result_path, :string

    timestamps()
  end
end
