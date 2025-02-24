defmodule Klepsidra.ReportJobs do
  @moduledoc """
  The `ReportJobs` context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo
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
  def create_report_job(attrs \\ %{}) do
    %ReportJob{}
    |> ReportJob.changeset(attrs)
    |> ReporterRepo.insert()
  end
end
