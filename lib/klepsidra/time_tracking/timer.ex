defmodule Klepsidra.TimeTracking.Timer do
  @moduledoc """
  Defines the `timers` schema and functions needed to clock in, out and
  parse datetimes.
  """

  use Private
  use Ecto.Schema

  import Ecto.Changeset
  alias Klepsidra.Categorisation.TimerTags
  alias Klepsidra.TimeTracking.ActivityType
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner
  alias Klepsidra.Cldr.Unit

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          start_stamp: String.t(),
          end_stamp: String.t(),
          duration: integer,
          duration_time_unit: String.t(),
          description: String.t(),
          billable: boolean,
          business_partner_id: integer,
          activity_type_id: binary(),
          billing_rate: number(),
          project_id: integer,
          billing_duration: integer,
          billing_duration_time_unit: String.t()
        }
  schema "timers" do
    field(:start_stamp, :string)
    field(:end_stamp, :string)
    field(:duration, :integer, default: nil)
    field(:duration_time_unit, :string)
    field(:description, :string)

    belongs_to(:project, Project, type: Ecto.UUID)

    field(:billable, :boolean, default: false)

    belongs_to(:business_partner, BusinessPartner, type: Ecto.UUID)
    belongs_to(:activity_type, ActivityType, type: Ecto.UUID)

    field(:billing_rate, :decimal)
    field(:billing_duration, :integer)
    field(:billing_duration_time_unit, :string)

    has_many(:timer_tags, TimerTags,
      preload_order: [asc: :tag_id],
      on_replace: :delete
    )

    has_many(:tags, through: [:timer_tags, :tag])

    has_many(:notes, Klepsidra.TimeTracking.Note, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(timer, attrs) do
    timer
    |> cast(attrs, [
      :start_stamp,
      :end_stamp,
      :duration,
      :duration_time_unit,
      :description,
      :project_id,
      :billable,
      :business_partner_id,
      :activity_type_id,
      :billing_rate,
      :billing_duration,
      :billing_duration_time_unit
    ])
    |> validate_required(:start_stamp, message: "Enter a start date and time")
    |> validate_timestamps_and_chronology(:start_stamp, :end_stamp)
    |> unique_constraint(:project)
  end

  @default_date_format Application.compile_env(:klepsidra, [__MODULE__, :default_date_format])
  @default_time_format Application.compile_env(:klepsidra, [__MODULE__, :default_time_format])

  @doc """
  Validate that the `end_timestamp` is chronologically after the `start_timestamp`.

  ## Options

      * `:message` - the message on failure, defaults to "Timestamps are not in valid order"

  """
  @spec validate_timestamps_and_chronology(
          changeset :: Ecto.Changeset.t(),
          start_timestamp :: atom,
          end_timestamp :: atom,
          opts :: Keyword.t()
        ) :: Ecto.Changeset.t()
  def validate_timestamps_and_chronology(changeset, start_timestamp, end_timestamp, opts \\ []) do
    _message = Keyword.get(opts, :message, "Timestamps are not in valid order")
    start_stamp = get_field(changeset, start_timestamp, "")

    parsed_start_stamp =
      case parse_html_datetime(start_stamp) do
        {:ok, start_datetime_stamp} -> start_datetime_stamp
        _ -> nil
      end

    end_stamp = get_field(changeset, end_timestamp, "") || ""

    parsed_end_stamp =
      case parse_html_datetime(end_stamp) do
        {:ok, end_datetime_stamp} -> end_datetime_stamp
        _ -> nil
      end

    with {:is_valid, true} <- {:is_valid, changeset.valid?},
         {:nonempty_start_stamp, true} <-
           {:nonempty_start_stamp, start_stamp != ""},
         {:valid_start_stamp, true} <-
           {:valid_start_stamp, is_struct(parsed_start_stamp, NaiveDateTime)},
         {:nonempty_end_stamp, true} <- {:nonempty_end_stamp, end_stamp != ""},
         {:valid_end_stamp, true} <-
           {:valid_end_stamp, is_struct(parsed_end_stamp, NaiveDateTime)},
         {:chronological_order, true} <-
           {:chronological_order, NaiveDateTime.before?(parsed_start_stamp, parsed_end_stamp)},
         {:reasonable_duration_check, true} <-
           {:reasonable_duration_check,
            NaiveDateTime.before?(
              parsed_end_stamp,
              NaiveDateTime.add(parsed_start_stamp, 24, :hour)
            )} do
      changeset
    else
      {:is_valid, false} ->
        changeset

      {:nonempty_start_stamp, false} ->
        add_error(changeset, :end_stamp, "You must provide a start time and date")

      {:valid_start_stamp, false} ->
        add_error(changeset, :end_stamp, "The start time and date is not valid")

      {:nonempty_end_stamp, false} ->
        changeset

      {:valid_end_stamp, false} ->
        add_error(changeset, :end_stamp, "The end time and date is not valid")

      {:chronological_order, false} ->
        add_error(changeset, :end_stamp, "The end time must follow the start time")

      {:reasonable_duration_check, false} ->
        add_error(changeset, :end_stamp, "The timed activity cannot be longer than one day")
    end
  end

  @doc """
  Get the current local date and time, without a timezone component,
  for the timezone the the computer the program is running on is set to.

  This function will display what the date and time are right now, for the
  time zone configuration the computer is localised to.

  Relying on this function to return the time is fine for many uses, including for
  timing tasks, but is unsuitable for use where real precision and time awareness may be
  critical.

  Returns a `NaiveDateTime` struct.

  ## Examples

      iex> naivedatetime_stamp = Klepsidra.TimeTracking.Timer.get_current_timestamp()
      iex> naivedatetime_stamp.year >= 2024
      true
  """
  @spec get_current_timestamp() :: NaiveDateTime.t()
  def get_current_timestamp do
    NaiveDateTime.local_now()
  end

  @doc """
  Calculates the time elapsed between start and end timestamps.

  The time unit can be passed in as the optional `unit` argument. If it is omitted,
  minutes are used as the default time unit.

  In calculating the time duration, the difference between the two timestamps is
  always incremented by one. This ensures that if the timer were simply started
  and immediately stopped, it would still register the use of one unit of time.

  If the start and end `datetime` stamps are empty strings, or nil values, returns
  zero duration to reduce the number of error conditions.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45")
      72

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :minute)
      72

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :second)
      4261

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :hour)
      2

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:34", :hour)
      2

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:33", :hour)
      1

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45])
      104

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :minute)
      104

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :second)
      6195

      iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration(~N[2024-06-06 23:40:31], ~N[2024-06-07 01:23:45], :hour)
      2
  """
  @spec calculate_timer_duration(String.t(), String.t(), atom()) :: integer()
  @spec calculate_timer_duration(NaiveDateTime.t(), NaiveDateTime.t(), atom()) :: integer()
  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute)

  def calculate_timer_duration("", "", _unit), do: 0
  def calculate_timer_duration(nil, nil, _unit), do: 0

  def calculate_timer_duration(start_timestamp, end_timestamp, unit)
      when is_bitstring(start_timestamp) and is_bitstring(end_timestamp) and is_atom(unit) do
    calculate_timer_duration(
      parse_html_datetime!(start_timestamp),
      parse_html_datetime!(end_timestamp),
      unit
    )
  end

  def calculate_timer_duration(start_timestamp, end_timestamp, unit)
      when is_struct(start_timestamp, NaiveDateTime) and
             is_struct(
               end_timestamp,
               NaiveDateTime
             ) and is_atom(unit) do
    with {:end_follows_start, true} <-
           {:end_follows_start, NaiveDateTime.after?(end_timestamp, start_timestamp)},
         {:uses_time_unit_primitive, true} <-
           {:uses_time_unit_primitive, unit in [:second, :minute, :hour, :day]} do
      NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1
    else
      {:end_follows_start, false} ->
        0

      {:uses_time_unit_primitive, false} ->
        (NaiveDateTime.diff(end_timestamp, start_timestamp, :minute) + 1)
        |> Cldr.Unit.new!(:minute)
        |> Klepsidra.Cldr.Unit.convert!(unit)
        |> Map.get(:value)
        |> Decimal.round(0, :up)
        |> Decimal.to_integer()
    end
  end

  @doc """
  Clock out of an active timer, given a starting timestamp string.

  ## Return values

  Returns a map containing the ending timestamp and duration in the requested unit of time.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      ...> |> NaiveDateTime.add(-15, :minute)
      ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      ...> |> Klepsidra.TimeTracking.Timer.clock_out()
      %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 16}

      iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      ...> |> NaiveDateTime.add(-15, :minute)
      ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      ...> |> Klepsidra.TimeTracking.Timer.clock_out(:hour)
      %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 1}
  """
  @spec clock_out(String.t(), atom()) :: %{end_timestamp: String.t(), timer_duration: integer()}
  def clock_out(start_timestamp, unit \\ :minute)
      when is_bitstring(start_timestamp) and is_atom(unit) do
    end_timestamp = get_current_timestamp()

    %{
      end_timestamp: convert_naivedatetime_to_html!(end_timestamp),
      timer_duration:
        calculate_timer_duration(
          parse_html_datetime!(start_timestamp),
          end_timestamp,
          unit
        )
    }
  end

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Datetime strings coming from HTML, from `datetime-local` type fields,
  are not conformant to the extended date and time of day  ISO 8601:2019 standard format.
  Specifically, they are encoded as "YYYY-MM-DDThh:mm", and are generally (but not always)
  passed without a seconds component. `NativeDateTime` cannot parse this, returning an
  error.

  Using the Timex library's `parse/2` function, parse datetime strings into an ISO
  conforming `NativeDateTime` structure, returning a result tuple:

  `{:ok, ~N[...]}` on success, or {:error, reason} upon failure.

  It is possible to receive a datetime with date and time components separated by either
  a letter "t" or a single space (" "), binary pattern matching will determine which is
  received in the `datetime_string` argument.

  An error is returned if the datetime string cannot be parsed as a valid date and time,
  and also if the string doesn't match the expected pattern.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15:39")
      {:ok, ~N[1970-01-01 11:15:39]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15:59")
      {:ok, ~N[1970-01-01 11:15:59]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-02-29T11:15")
      {:error, :invalid_date}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("")
      {:error, "Invalid argument passed as timestamp"}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime(nil)
      {:error, "Invalid argument passed as timestamp"}
  """
  @spec parse_html_datetime(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, String.t()}
  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}")
  end

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  def parse_html_datetime(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end

  def parse_html_datetime(_), do: {:error, "Invalid argument passed as timestamp"}

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Works just like `parse_html_datetime\1`, but instead of returning an {:ok, _} or
  {:error, reason} tuple, returns the `NaiveDateTime` struct on success, raising
  an error otherwise.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01T11:15")
      ~N[1970-01-01 11:15:00]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01T11:15:39")
      ~N[1970-01-01 11:15:39]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01 11:15")
      ~N[1970-01-01 11:15:00]

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime!("1970-01-01 11:15:59")
      ~N[1970-01-01 11:15:59]

  """
  @spec parse_html_datetime!(String.t()) :: NaiveDateTime.t()
  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end

  @doc """
  Converts `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a tuple with `:ok` or `:error` as the first element, with a string
  compatible with HTML's input `datetime-local` element, in the format
  "YYYY-MM-DDThh:mm". This can directly be fed into an `input` element's `value`
  slot.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html(~N[2024-04-07 22:12:32])
      {:ok, "2024-04-07T22:12:32"}
  """
  @spec convert_naivedatetime_to_html(NaiveDateTime.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def convert_naivedatetime_to_html(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  @doc """
  Converts `NativeDateTime` structure to HTML-ready string, with the seconds component
  elided.

  Returns a string compatible with HTML's input `datetime-local` element, in the
  format "YYYY-MM-DDThh:mm". This can directly be fed into an `input` element's
  `value` slot.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(~N[2024-04-07 22:12:32])
      "2024-04-07T22:12:32"
  """
  @spec convert_naivedatetime_to_html!(NaiveDateTime.t()) :: String.t()
  def convert_naivedatetime_to_html!(datetime_stamp)
      when is_struct(datetime_stamp, NaiveDateTime) do
    Timex.format!(datetime_stamp, "{YYYY}-{0M}-{0D}T{0h24}:{0m}:{0s}")
  end

  @doc """
  Formats a number into a string according to a unit definition for a locale.

  Takes an integer duration, and an atom time unit, including any custom time
  units defined and compiled as part of this project.

  Returns a tuple {:ok, ...} containing a locale-specific and quantity-sensitive
  pluralisation of the defined time unit as a string.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(3, :minute)
      {:ok, "3 minutes"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(7, :six_minute_increment)
      {:ok, "7 six minute increments"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(1, :hour)
      {:ok, "1 hour"}

      iex> Klepsidra.TimeTracking.Timer.duration_to_string(0, :second)
      {:ok, "0 seconds"}
  """
  @spec duration_to_string(integer(), atom()) :: []
  def duration_to_string(duration, time_unit) when is_integer(duration) and is_atom(time_unit) do
    Cldr.Unit.to_string(Cldr.Unit.new!(time_unit, duration), Klepsidra.Cldr)
  end

  @doc """
  Used across `timer` live components to calculate timer durations.

  The function takes the `timer_params` parameters passed to the validation function,
  extracts the start and end datetime stamps, returning a map with the two
  calculated durations: `%{duration: 0, billing_duration: 0}`
  """
  @spec assign_timer_duration(%{optional(any) => any}, String.t()) :: integer()
  def assign_timer_duration(timer_params, duration_time_unit)
      when is_map(timer_params) and is_bitstring(duration_time_unit) do
    start_stamp = timer_params["start_stamp"]
    end_stamp = timer_params["end_stamp"]
    duration_time_unit = timer_params[duration_time_unit]

    with true <- start_stamp != "",
         true <- end_stamp != "",
         true <- duration_time_unit != "" do
      calculate_timer_duration(
        start_stamp,
        end_stamp,
        String.to_atom(duration_time_unit)
      )
    else
      _ -> 0
    end
  end

  def read_checkbox(field) do
    Phoenix.HTML.Form.normalize_value("checkbox", field)
  end

  @doc """
  Takes in a single duration tuple, shaped as `{duration, string_duration_time_unit}`,
  converting it to a duration in seconds, the base time unit.
  """
  @spec convert_duration_to_base_time_unit({integer, bitstring()}) :: Cldr.Unit
  def convert_duration_to_base_time_unit(duration_tuple)
      when is_tuple(duration_tuple) and tuple_size(duration_tuple) == 2 do
    {duration, duration_time_unit} = duration_tuple

    Unit.new!(duration, convert_string_to_time_unit_atom(duration_time_unit))
    |> Unit.convert!(:second)
  end

  @doc """
  Takes in a list of duration tuples, shaped as `{duration, string_duration_time_unit}`,
  converting them all to durations in seconds, the base time unit.
  """
  @spec convert_durations_to_base_time_unit([{integer, bitstring()}, ...]) :: [Cldr.Unit, ...]
  def convert_durations_to_base_time_unit(durations_list)
      when is_list(durations_list) do
    durations_list
    |> Enum.map(fn duration_tuple -> convert_duration_to_base_time_unit(duration_tuple) end)
  end

  @spec convert_string_to_time_unit_atom(String.t()) :: atom()
  defp convert_string_to_time_unit_atom(time_unit) when is_bitstring(time_unit) do
    cond do
      time_unit == "minute" -> :minute_increment
      time_unit == "hour" -> :hour_increment
      true -> String.to_existing_atom(time_unit)
    end
  end

  @doc """
  Takes a list of `Cldr.Unit` structures, timed in the base unit for time,
  seconds, summing them all to return a total duration in the same time unit.
  """
  @spec sum_base_unit_durations([Cldr.Unit, ...]) :: bitstring()
  def sum_base_unit_durations(durations_list)
      when is_list(durations_list) do
    durations_list
    |> Enum.reduce(Unit.new!(:second, 0), fn i, acc ->
      Unit.add(i, acc)
    end)
  end

  @doc """
  Takes two `Cldr.Unit` structures, the aggregate time and the latest deleted timer,
  timed in, seconds, the base unit of time, returning the result of their difference.
  """
  @spec subtract_base_unit_durations(map(), map()) :: Cldr.Unit
  def subtract_base_unit_durations(duration_1, duration_2)
      when is_struct(duration_1, Cldr.Unit) and is_struct(duration_2, Cldr.Unit) do
    Unit.sub!(duration_1, duration_2)
  end

  @doc """
  Takes in a `Cldr.Unit` structure, denoting a duration, decomposing it into
  human-intuitive time increments, rounding it to the nearest of each unit,
  formatting it all as an easy to read string.

  By default, the decomposition will be into hours and minutes, but a list
  consisting of any time increment can be used here, e.g.:
  `[:day, :hour_increment, :minute_increment]`.

  A zero time value will return a nil result.

  ## Examples

      #iex> 3600 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      #"1 hour"
      #iex> 0 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      #nil
      #iex> 5000 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration()
      #"1 hour and 23 minutes"
      #iex> 95000 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration(unit_list: [:hour_increment, :minute_increment])
      #"26 hours and 23 minutes"
      #iex> 95000 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration(unit_list: [:day, :hour_increment, :minute_increment])
      #"1 day, 2 hours and 23 minutes"
      #iex> 95000 |> Cldr.Unit.new!(:second) |> Klepsidra.TimeTracking.Timer.format_human_readable_duration(unit_list: [:day, :hour_increment])
      #"1 day and 2 hours"
  """
  # @spec format_human_readable_duration(%{unit: atom(), value: integer()}, list()) ::
  #         nil | bitstring()
  def format_human_readable_duration(duration, options \\ [])
      when is_struct(duration, Cldr.Unit) do
    unit_list =
      Keyword.get(options, :unit_list, [:hour_increment, :minute_increment])

    # return_if_short_duration = Keyword.get(options, :return_if_short_duration, true)

    case decompose_unit(duration, unit_list, restrict_if_components_only: [:hour_increment]) do
      nil ->
        nil

      unit_composition ->
        unit_composition
        |> Enum.map(fn i -> Unit.round(i, 0) end)
        |> then(fn
          [] -> nil
          list -> Unit.to_string!(list)
        end)
    end
  end

  @doc """
  Decompose a unit into component subunits.

  Any list compatible units can be provided however a list of units of
  decreasing scale is recommended.

  ## Arguments

  * `unit` is any unit returned by `Cldr.Unit.new/2`
  * `subunit_list` is a list of valid units. All units must be from the same
    category

  ## Returns

  A map containing:

  * `number_of_subunits` the number of component subunits
  * `unit_composition` a list of units after decomposition

  ## Examples

      iex>  21.17 |> Cldr.Unit.new!(:hour_increment) |> Klepsidra.TimeTracking.Timer.decompose_unit([:day, :hour_increment])
      [Cldr.Unit.new!(:hour_increment, "21.1699999999999992")]

      iex> 121.17 |> Cldr.Unit.new!(:hour_increment) |> Klepsidra.TimeTracking.Timer.decompose_unit([:day, :hour_increment])
      [Cldr.Unit.new!(:day, 5), Cldr.Unit.new!(:hour_increment, "1.17")]

      iex> 21.17  |> Klepsidra.TimeTracking.Timer.decompose_unit([:day, :hour_increment])
      {:error, "Invalid unit or subunit_list"}

      iex> 21.17 |> Cldr.Unit.new!(:hour_increment) |> Klepsidra.TimeTracking.Timer.decompose_unit("")
      {:error, "Invalid unit or subunit_list"}
  """
  @spec decompose_unit(%{unit: atom(), value: integer()}, list(), keyword()) ::
          nil | list()
  def decompose_unit(unit, subunit_list, options \\ [])

  def decompose_unit(unit, subunit_list, options)
      when is_struct(unit, Cldr.Unit) and is_list(subunit_list) do
    restrict_if_components_only = Keyword.get(options, :restrict_if_components_only, nil)

    Unit.decompose(unit, subunit_list)
    |> adjust_for_restricted_subunits(restrict_if_components_only)
  end

  def decompose_unit(_unit, _subunit_list, _options),
    do: {:error, "Invalid unit or subunit_list"}

  private do
    @spec adjust_for_restricted_subunits([atom(), ...], list()) ::
            nil | [%{unit: atom(), value: non_neg_integer() | float()}]
    def adjust_for_restricted_subunits(unit_composition, [_ | _] = restricted_subunits)
        when is_list(unit_composition) do
      restricted_list = MapSet.new(restricted_subunits)

      unit_composition
      |> Enum.reject(fn %{unit: unit} -> MapSet.member?(restricted_list, unit) end)
      |> non_empty_list?(unit_composition)
    end

    def adjust_for_restricted_subunits(unit_composition, _), do: unit_composition
  end

  private do
    @spec non_empty_list?(nonempty_list(), list()) :: as_boolean(term)
    def non_empty_list?([], _), do: nil
    def non_empty_list?(list, []) when is_list(list), do: list
    def non_empty_list?(_list, return) when is_list(return), do: return
  end

  @doc """
  Format a `NaiveDateTime` into human readable date.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.format_human_readable_date(~N[2024-01-23 12:34:56])
      {:ok, "Tuesday, 23 Jan 2024"}
  """
  @spec format_human_readable_date(NaiveDateTime.t()) ::
          {:ok, bitstring()} | {:error, {atom(), binary()}}
  def format_human_readable_date(datetime, format_string \\ @default_date_format)
      when is_struct(datetime, NaiveDateTime) and is_bitstring(format_string) do
    Timex.format(datetime, format_string)
  end

  @doc """
  Format a `NaiveDateTime` into a human-readable time, displaying hours and minutes by default, in 24-hour time, returning a tuple with the return status and the formatted time string.

  ## Arguments

  * `datetime`, a valid `NaiveDateTime` structure
  * `format_string`, an optional format string, in `Timex` default formatting language.

  ## Returns

  A tuple with return status and a string, either

  * {:ok, formatted time string}

  or

  * {:error, error message}

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.format_human_readable_time(~N[2024-01-23 12:34:56])
      {:ok, "12:34"}
  """
  @spec format_human_readable_time(NaiveDateTime.t()) :: {:ok | :error, bitstring()}
  def format_human_readable_time(datetime, format_string \\ @default_time_format)
      when is_struct(datetime, NaiveDateTime) and is_bitstring(format_string) do
    Timex.format(datetime, format_string)
  end

  @doc """
  Format a `NaiveDateTime` into a human-readable time, displaying hours and minutes by default, in 24-hour time.

  ## Arguments

  * `datetime`, a valid `NaiveDateTime` structure
  * `format_string`, an optional format string, in `Timex` default formatting language.

  ## Returns

  * formatted time string, or an exception on error

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.format_human_readable_time!(~N[2024-01-23 12:34:56])
      "12:34"
  """
  @spec format_human_readable_time!(NaiveDateTime.t()) :: bitstring()
  def format_human_readable_time!(datetime, format_string \\ @default_time_format)
      when is_struct(datetime, NaiveDateTime) and is_bitstring(format_string) do
    Timex.format!(datetime, format_string)
  end
end
