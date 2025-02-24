defmodule Klepsidra.Utilities.NamingUtilities do
  @moduledoc """
  This module handles naming conversion, namely that of
  underscore-delimited naming-as used in Elixir-to camel-cased
  naming-as used in Java.
  """

  alias Phoenix.Naming

  @doc """
  Takes a regular Elixir map, using standard underscore-delimited key
  naming, converting all keys to Java Beans-compatible camel case
  naming format, finally returning a string-based map with Java-named
  string keys.
  """
  @spec underscore_map_to_camel_case(map :: map()) :: map()
  def underscore_map_to_camel_case(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {camel_case_key(key), value} end)
    |> Enum.into(%{})
  end

  @doc """
  Converts a map's key to Java-compatible camel case naming
  format: a string beginning with a lowercase letter, followed
  by a capital letter at the start of each new word.
  """
  @spec camel_case_key(key :: atom() | binary()) :: binary()
  def camel_case_key(key) when is_atom(key) do
    key
    |> Atom.to_string()
    |> Naming.camelize(:lower)
  end

  def camel_case_key(key) when is_binary(key) do
    key
    |> Naming.camelize(:lower)
  end
end
