defmodule Klepsidra.Reporting.ReportTableManager do
  @moduledoc """
  This module is responsible for automatically generating temporary report data
  tables. 
  """

  alias Klepsidra.ReporterRepo

  @doc """
  Generate a unique temporary table to hold input data for a single report.
  Following the successful generation of that report, reaching the maximum
  permitted attempts at generation, cancellation or discarding of the job,
  this table will be dropped so as not to become part of a _memory leak_ as
  well as to safeguard data confidentiality and privacy.
  """
  @spec create_temporary_table(
          report_job_id :: Ecto.UUID.t(),
          report_name :: String.t(),
          dataset :: [map(), ...]
        ) :: String.t()
  def create_temporary_table(report_job_id, report_name, dataset)
      when is_bitstring(report_name) and is_list(dataset) and dataset != [] do
    table_name = construct_table_name(report_job_id, report_name)

    # Infer field types from first record
    columns = infer_column_types(List.first(dataset))

    # Generate CREATE TABLE SQL statement
    create_table_sql_statement = generate_create_table_sql(table_name, columns)

    # Execute table creation
    ReporterRepo.query!(create_table_sql_statement)

    # Insert data
    insert_dataset_into_table(table_name, dataset, columns)
  end

  @spec delete_temporary_table(report_job_id :: Ecto.UUID.t(), report_name :: String.t()) ::
          Exqlite.Result.t()
  def delete_temporary_table(report_job_id, report_name)
      when is_bitstring(report_job_id) and is_bitstring(report_name) do
    table_name = construct_table_name(report_job_id, report_name)

    # Generate DROP TABLE SQL statement
    drop_table_sql_statement = generate_drop_table_sql(table_name)

    # Execute table deletion
    ReporterRepo.query!(drop_table_sql_statement)
  end

  @spec construct_table_name(report_job_id :: Ecto.UUID.t(), report_name :: String.t()) ::
          bitstring()
  defp construct_table_name(report_job_id, report_name) do
    "report_#{report_name}_#{report_job_id |> String.replace("-", "_")}"
  end

  @doc """
  Takes a single `record` map, inspect all its fields, or _keys_, returning a
  list definition of all the record's fields and their respective types. This
  deconstruction will be used to define a temporary database table modeled to
  hold the requested report's input dataset.
  """
  @spec infer_column_types(record :: any()) :: [{atom(), bitstring()}, ...]
  def infer_column_types(record) when is_map(record) do
    record
    |> Map.to_list()
    |> Enum.map(fn {field, value} ->
      type = infer_column_type(value)
      {field, type}
    end)
  end

  @spec infer_column_type(value :: any()) :: String.t()
  defp infer_column_type(value) when is_nil(value), do: "TEXT"
  defp infer_column_type(true), do: "BOOLEAN"
  defp infer_column_type(false), do: "BOOLEAN"
  defp infer_column_type(value) when is_boolean(value), do: "BOOLEAN"
  defp infer_column_type(value) when is_atom(value), do: "ATOM"
  defp infer_column_type(value) when is_float(value), do: "REAL"
  defp infer_column_type(value) when is_integer(value), do: "INTEGER"
  defp infer_column_type(value) when is_number(value), do: "INTEGER"
  defp infer_column_type(value) when is_binary(value), do: "TEXT"
  defp infer_column_type(value) when is_list(value), do: "JSON"
  defp infer_column_type(value) when is_tuple(value), do: "TEXT"
  defp infer_column_type(value) when is_struct(value, NaiveDateTime), do: "TEXT"
  defp infer_column_type(value) when is_struct(value, DateTime), do: "TEXT"
  defp infer_column_type(value) when is_struct(value, Date), do: "TEXT"
  defp infer_column_type(value) when is_map(value), do: "MAP"
  # Fallback type
  defp infer_column_type(_), do: "TEXT"

  @spec generate_create_table_sql(table_name :: String.t(), [{atom(), String.t()}]) :: String.t()
  defp generate_create_table_sql(table_name, columns) do
    column_definitions =
      columns
      |> Enum.map(fn {field, type} -> "#{field} #{type}" end)
      |> Enum.join(", ")

    "CREATE TABLE IF NOT EXISTS #{table_name} (#{column_definitions}) WITHOUT ROWID;"
  end

  @spec generate_drop_table_sql(table_name :: String.t()) :: String.t()
  defp generate_drop_table_sql(table_name) do
    "DROP TABLE IF EXISTS #{table_name};"
  end

  defp insert_dataset_into_table(table_name, dataset, columns) do
    column_names = columns |> Enum.map(fn {field, _} -> field end)

    # <>
    insert_sql =
      "INSERT INTO #{table_name} (#{Enum.join(column_names, ", ")}) VALUES "

    # Enum.map(dataset, fn record ->
    #   values = Enum.map(column_names, &"'#{Map.get(record, &1)}'")
    #   "(#{Enum.join(values, ", ")})"
    # end))
    # |> Enum.join(", ")

    # Repo.query!(insert_sql)
  end
end
