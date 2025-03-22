defmodule Klepsidra.ReportJobs do
  @moduledoc """
  The `ReportJobs` context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.ReporterRepo
  alias Klepsidra.Reports.ReportJob

  @doc """
  Gets a single report job.

  Raises `Ecto.NoResultsError` if the report job does not exist.

  ## Examples

      iex> get_report_job!(123)
      %ReportJob{}

      iex> get_report_job!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_report_job!(id :: Ecto.UUID.t()) :: ReportJob.t()
  def get_report_job!(id), do: ReporterRepo.get!(ReportJob, id)

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
  Updates a report job.

  ## Examples

      iex> update_report_job(report_job, %{field: new_value})
      {:ok, %ReportJob{}}

      iex> update_report_job(report_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_report_job(report_job :: ReportJob.t(), attrs :: map()) ::
          {:ok, ReportJob.t()} | {:error, Ecto.Changeset.t()}
  def update_report_job(%ReportJob{} = report_job, attrs) do
    report_job
    |> ReportJob.changeset(attrs)
    |> ReporterRepo.update()
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
