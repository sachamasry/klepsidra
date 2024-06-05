defmodule Klepsidra.TimeTracking.Timer do
  @moduledoc """
  Defines the `timers` schema and functions needed to clock in, out and parse datetimes.
  """

  use Ecto.Schema

  import Ecto.Changeset
  alias Klepsidra.Categorisation.TimerTags
  alias Klepsidra.Projects.Project
  alias Klepsidra.BusinessPartners.BusinessPartner

  @type t :: %__MODULE__{
          start_stamp: String.t(),
          end_stamp: String.t(),
          duration: integer,
          duration_time_unit: String.t(),
          description: String.t(),
          billable: boolean,
          business_partner_id: integer,
          project_id: integer,
          reported_duration: integer,
          reported_duration_time_unit: String.t()
        }
  schema "timers" do
    field :start_stamp, :string
    field :end_stamp, :string
    field :duration, :integer, default: nil
    field :duration_time_unit, :string
    field :description, :string
    field :billable, :boolean, default: false

    belongs_to :business_partner, BusinessPartner
    belongs_to :project, Project

    field :reported_duration, :integer
    field :reported_duration_time_unit, :string

    has_many :timer_tags, TimerTags,
      preload_order: [asc: :tag_id],
      on_replace: :delete

    has_many :tags, through: [:timer_tags, :tag]

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
      :billable,
      :business_partner_id,
      :project_id,
      :reported_duration,
      :reported_duration_time_unit
    ])
    |> validate_required([:start_stamp])
    |> unique_constraint(:project)
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

  ## Examples

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45")
      # 72

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :minute)
      # 72

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :second)
      # 4261

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:45", :hour)
      # 2

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:34", :hour)
      # 2

      # iex> Klepsidra.TimeTracking.Timer.calculate_timer_duration("2024-02-28 12:34", "2024-02-28 13:33", :hour)
      # 1
  """
  @spec calculate_timer_duration(String.t(), String.t(), atom()) :: integer()
  @spec calculate_timer_duration(NaiveDateTime.t(), NaiveDateTime.t(), atom()) :: integer()
  def calculate_timer_duration(start_timestamp, end_timestamp, unit \\ :minute)

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
    if unit in [:second, :minute, :hour, :day] do
      NaiveDateTime.diff(end_timestamp, start_timestamp, unit) + 1
    else
      (NaiveDateTime.diff(end_timestamp, start_timestamp, :minute) + 1)
      |> Cldr.Unit.new!(:minute)
      |> Klepsidra.Cldr.Unit.convert!(unit)
      |> Map.get(:value)
      |> Decimal.round(0, :up)
    end
  end

  @doc """
  Clock out of an active timer, given a starting timestamp string.

  ## Return values

  Returns a map containing the ending timestamp and duration in the requested unit of time.

  ## Examples

      # iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      # ...> |> NaiveDateTime.add(-15, :minute)
      # ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      # ...> |> Klepsidra.TimeTracking.Timer.clock_out()
      # %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 16}

      # iex> Klepsidra.TimeTracking.Timer.get_current_timestamp()
      # ...> |> NaiveDateTime.add(-15, :minute)
      # ...> |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!()
      # ...> |> Klepsidra.TimeTracking.Timer.clock_out(:hour)
      # %{end_timestamp: Klepsidra.TimeTracking.Timer.get_current_timestamp() |> Klepsidra.TimeTracking.Timer.convert_naivedatetime_to_html!(), timer_duration: 1}
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

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-02-29T11:15")
      {:error, :invalid_date}
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

  @doc """
  Parses HTML `datetime-local` strings into `NativeDateTime` structure.

  Works just like `parse_html_datetime\1`, but instead of returning an {:ok, _} or
  {:error, reason} tuple, returns the `NaiveDateTime` struct on success, otherwise
  raises an error.

  ## Examples

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01T11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

      iex> Klepsidra.TimeTracking.Timer.parse_html_datetime("1970-01-01 11:15")
      {:ok, ~N[1970-01-01 11:15:00]}

  """
  @spec parse_html_datetime!(String.t()) :: NaiveDateTime.t()
  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), "T",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D}T{0h24}:{0m}")
  end

  def parse_html_datetime!(
        <<_year::binary-size(4), "-", _month::binary-size(2), "-", _day::binary-size(2), " ",
          _hour::binary-size(2), ":", _minute::binary-size(2), ":",
          _second::binary-size(2)>> = datetime_string
      )
      when is_bitstring(datetime_string) do
    Timex.parse!(datetime_string, "{YYYY}-{0M}-{0D} {0h24}:{0m}")
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
end
