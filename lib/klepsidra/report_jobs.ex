defmodule Klepsidra.ReportJobs do
  @moduledoc """
  The `ReportJobs` context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.ReporterRepo
  alias Klepsidra.Reports.ReportJob

  @doc """
  Creates a new report job, adding it to the queue.

  ## Examples

      iex> create_report_job(%{field: value})
      {:ok, %ReportJob{}}

      iex> create_report_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_report_job(attrs :: map()) :: {:ok, ReportJob.t()} | {:error, Ecto.Changeset.t()}
  def create_report_job(attrs \\ %{}) do
    %ReportJob{}
    |> ReportJob.changeset(attrs)
    |> ReporterRepo.insert()
  end

  @doc """
  Retrieve jobs matching `state`, by default "completed".
  """
  @spec get_completed_jobs(state :: bitstring()) :: [ReportJob.t(), ...]
  def get_completed_jobs(state \\ "completed") when is_bitstring(state) do
    ReportJob
    |> where(state: ^state)
    |> order_by(asc: :inserted_at)
    |> ReporterRepo.all()
  end
end
