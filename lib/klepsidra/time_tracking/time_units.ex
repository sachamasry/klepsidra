defmodule Klepsidra.TimeTracking.TimeUnits  do
  @moduledoc """
  Provides handling and user interface presentation of time units.
  """

  @locale :en
  @style :narrow
  @default_billing_increment :thirty_minute_increment

  @doc """
  Returns the default billing increment for use in option select controls'
  value property.

  The returned value is a string, to be immediately usable, without further
  conversion.
  """
  @spec get_default_billing_increment() :: String.t()
  def get_default_billing_increment() do
    Atom.to_string(@default_billing_increment)
  end

  @doc """
  Constructs a list of time units, ready to be used in an `options` input element.

  Returns list of tuples of the user-facing unit name and string version of the
  time unit atom. For example, weeks would be presented as: `{"Weeks", "week"}`.
  """
  @spec construct_duration_unit_options_list() :: [{String.t(), String.t()}]
  def construct_duration_unit_options_list(opts \\ []) do
    use_time_primitives? = Keyword.get(opts, :use_primitives?, false)
    IO.inspect(use_time_primitives?, label: "Primitives")

    case use_time_primitives? do
      true ->
        [{"Seconds", "second"}, {"Minutes", "minute"}, {"Hours", "hour"}]

      false ->
        [
          {"Minutes", "minute"} |
          Klepsidra.Cldr.Unit.Additional.units_for(@locale, @style)
          |> Enum.map(fn {k, v} -> {v.display_name, Atom.to_string(k)} end)
        ]
    end
  end
end
