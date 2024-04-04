defmodule Klepsidra.TimeTracking.TimeUnits do
  @moduledoc """
  Provides handling and user interface presentation of time units.
  """

  alias Klepsidra.Cldr.Unit.Additional, as: AdditionalUnits

  @locale :en
  @style :narrow
  @default_billing_increment :thirty_minute_increment

  @doc """
  Returns the default billing increment for use in option select controls'
  value property.

  The returned value is a string, to be immediately usable, without further
  conversion. The default is stored, compiled, in the module attribute
  `@default_billing_increment`, which will be supplanted in the future by
  a user-defined choice, directly in the user interface.
  """
  @spec get_default_billing_increment() :: String.t()
  def get_default_billing_increment do
    Atom.to_string(@default_billing_increment)
  end

  @doc """
  Constructs a list of time units, ready to be used in an `options` input element.

  Returns list of tuples of the user-facing unit name and string version of the
  time unit atom, shaped for use in Phoenix-constructed [HTML] option input elements.
  Each tuple has two elements, the first human-readable value, the second
  is the string version of the time unit atom name.

  For example, weeks would be presented as: `{"Weeks", "week"}`.

  ## Examples

      iex> Klepsidra.TimeTracking.TimeUnits.construct_duration_unit_options_list()
      [
        {"Minutes", "minute"},
        {"5 min", "five_minute_increment"},
        {"6 min", "six_minute_increment"},
        {"10 min", "ten_minute_increment"},
        {"12 min", "twelve_minute_increment"},
        {"15 min", "fifteen_minute_increment"},
        {"18 min", "eighteen_minute_increment"},
        {"20 min", "twenty_minute_increment"},
        {"24 min", "twenty_four_minute_increment"},
        {"30 min", "thirty_minute_increment"},
        {"36 min", "thirty_six_minute_increment"},
        {"45 min", "fourty_five_minute_increment"},
        {"60 min", "sixty_minute_increment"},
        {"90 min", "ninety_minute_increment"},
        {"2 hour increment", "one_hundred_twenty_minute_increment"}
      ]

      iex> Klepsidra.TimeTracking.TimeUnits.construct_duration_unit_options_list(use_primitives?: true)
      [{"Seconds", "second"}, {"Minutes", "minute"}, {"Hours", "hour"}]
  """
  @spec construct_duration_unit_options_list() :: [{String.t(), String.t()}]
  def construct_duration_unit_options_list(opts \\ []) do
    use_time_primitives? = Keyword.get(opts, :use_primitives?, false)

    case use_time_primitives? do
      true ->
        [{"Seconds", "second"}, {"Minutes", "minute"}, {"Hours", "hour"}]

      false ->
        [
          {"Minutes", "minute"}
          | AdditionalUnits.units_for(@locale, @style)
            |> Enum.map(fn {k, v} -> {v.display_name, Atom.to_string(k)} end)
        ]
    end
  end
end
