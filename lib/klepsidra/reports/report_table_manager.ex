defmodule Klepsidra.Reporting.ReportTableManager do
  @moduledoc """
  This module is responsible for automatically generating temporary report data
  tables. 
  """

  # alias Klepsidra.ReporterRepo

  @doc """
  Takes a single `record` map, inspect all its fields, or _keys_, returning a
  list definition of all the record's fields and their respective types. This
  deconstruction will be used to define a temporary database table modeled to
  hold the requested report's input dataset.
  """
  @spec infer_columns(record :: any()) :: [{atom(), bitstring()}, ...]
  def infer_columns(record) when is_map(record) do
    record
    |> Map.to_list()
    |> Enum.map(fn {field, value} ->
      type = infer_type(value)
      {field, type}
    end)
  end

  @spec infer_type(value :: any()) :: String.t()
  defp infer_type(value) when is_nil(value), do: "TEXT"
  defp infer_type(true), do: "BOOLEAN"
  defp infer_type(false), do: "BOOLEAN"
  defp infer_type(value) when is_boolean(value), do: "BOOLEAN"
  defp infer_type(value) when is_atom(value), do: "ATOM"
  defp infer_type(value) when is_float(value), do: "REAL"
  defp infer_type(value) when is_integer(value), do: "INTEGER"
  defp infer_type(value) when is_number(value), do: "INTEGER"
  defp infer_type(value) when is_binary(value), do: "TEXT"
  defp infer_type(value) when is_list(value), do: "JSON"
  defp infer_type(value) when is_tuple(value), do: "TEXT"
  defp infer_type(value) when is_struct(value, NaiveDateTime), do: "TEXT"
  defp infer_type(value) when is_struct(value, DateTime), do: "TEXT"
  defp infer_type(value) when is_struct(value, Date), do: "TEXT"
  defp infer_type(value) when is_map(value), do: "MAP"
  # Fallback type
  defp infer_type(_), do: "TEXT"
end
