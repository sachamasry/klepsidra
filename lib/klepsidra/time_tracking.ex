defmodule Klepsidra.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias Klepsidra.Repo

  alias Klepsidra.TimeTracking.Timer

  @doc """
  Returns the list of timers.

  ## Examples

      iex> list_timers()
      [%Timer{}, ...]

  """
  def list_timers do
    Repo.all(Timer)
  end

  @doc """
  Gets a single timer.

  Raises `Ecto.NoResultsError` if the Timer does not exist.

  ## Examples

      iex> get_timer!(123)
      %Timer{}

      iex> get_timer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timer!(id), do: Repo.get!(Timer, id)

  @doc """
  Gets a list of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timers_for_date(NaiveDateTime.t()) ::
          [Klepsidra.TimeTracking.Timer.t(), ...] | []
  def get_closed_timers_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in "timers",
        select: %Timer{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          description: at.description,
          inserted_at: at.inserted_at
        },
        where:
          at.start_stamp >= type(^start_of_day, :naive_datetime) and
            at.start_stamp <= type(^end_of_day, :naive_datetime) and
            not is_nil(at.end_stamp),
        order_by: [desc: at.inserted_at, asc: at.id]
      )

    Repo.all(query)
  end

  @doc """
  Gets a count of closed timers started on the specified date.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_count_for_date(NaiveDateTime.t()) :: integer()
  def get_closed_timer_count_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in "timers",
        select: count(at.id),
        where:
          at.start_stamp >= type(^start_of_day, :naive_datetime) and
            at.start_stamp <= type(^end_of_day, :naive_datetime) and
            not is_nil(at.end_stamp)
      )

    Repo.one(query)
  end

  @doc """
  Gets a sum of timer durations for the specified date, by time unit.

  A closed timer is one which has an end datetime stamp recorded, as well as
  a starting one.
  """
  @spec get_closed_timer_durations_for_date(NaiveDateTime.t()) ::
          [{integer, bitstring()}, ...] | []
  def get_closed_timer_durations_for_date(date) when is_struct(date, NaiveDateTime) do
    start_of_day = NaiveDateTime.beginning_of_day(date)
    end_of_day = NaiveDateTime.add(start_of_day, 24, :hour)

    query =
      from(
        at in "timers",
        select: {sum(at.duration), at.duration_time_unit},
        group_by: at.duration_time_unit,
        where:
          at.start_stamp >= type(^start_of_day, :naive_datetime) and
            at.start_stamp <= type(^end_of_day, :naive_datetime) and
            not is_nil(at.end_stamp)
      )

    Repo.all(query)
  end

  @doc """
  Gets a list of all open timers.

  A timer is considered open if it has no `end_stamp`.
  """
  @spec get_all_open_timers() :: [Klepsidra.TimeTracking.Timer.t(), ...] | []
  def get_all_open_timers() do
    query =
      from(
        at in "timers",
        select: %Timer{
          id: at.id,
          start_stamp: at.start_stamp,
          end_stamp: at.end_stamp,
          duration: at.duration,
          duration_time_unit: at.duration_time_unit,
          description: at.description,
          inserted_at: at.inserted_at
        },
        where:
          not is_nil(at.start_stamp) and
            is_nil(at.end_stamp),
        order_by: [desc: at.start_stamp, desc: at.inserted_at]
      )

    Repo.all(query)
  end

  @doc """
  Creates a timer.

  ## Examples

      iex> create_timer(%{field: value})
      {:ok, %Timer{}}

      iex> create_timer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timer(attrs \\ %{}) do
    %Timer{}
    |> Timer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timer.

  ## Examples

      iex> update_timer(timer, %{field: new_value})
      {:ok, %Timer{}}

      iex> update_timer(timer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timer(%Timer{} = timer, attrs) do
    timer
    |> Timer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timer.

  ## Examples

      iex> delete_timer(timer)
      {:ok, %Timer{}}

      iex> delete_timer(timer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timer(%Timer{} = timer) do
    Repo.delete(timer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timer changes.

  ## Examples

      iex> change_timer(timer)
      %Ecto.Changeset{data: %Timer{}}

  """
  def change_timer(%Timer{} = timer, attrs \\ %{}) do
    Timer.changeset(timer, attrs)
  end

  alias Klepsidra.TimeTracking.Note

  @doc """
  Returns the list of notes.

  ## Examples

      iex> list_notes()
      [%Note{}, ...]

  """
  def list_notes do
    Repo.all(Note)
  end

  @doc """
  Returns a list of notes matching the given `filter`.

  Example filter:

  %{timer_id: 42}
  """
  def list_notes(filter) when is_map(filter) do
    # from(Note)
    # |> filter_notes_by_timer(filter)
    # |> Repo.all()
  end

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id), do: Repo.get!(Note, id)

  @doc false
  def get_note_by_timer_id!(timer_id) do
    Note
    |> where(timer_id: ^timer_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Creates a note.

  ## Examples

      iex> create_note(%{field: value})
      {:ok, %Note{}}

      iex> create_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note.

  ## Examples

      iex> delete_note(note)
      {:ok, %Note{}}

      iex> delete_note(note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(note)
      %Ecto.Changeset{data: %Note{}}

  """
  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  alias Klepsidra.TimeTracking.ActivityType

  @doc """
  Returns the list of activity_types.

  ## Examples

      iex> list_activity_types()
      [%ActivityType{}, ...]

  """
  def list_activity_types do
    Repo.all(ActivityType)
  end

  @doc """
  Gets a single activity_type.

  Raises `Ecto.NoResultsError` if the Activity type does not exist.

  ## Examples

      iex> get_activity_type!(123)
      %ActivityType{}

      iex> get_activity_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity_type!(id), do: Repo.get!(ActivityType, id)

  @doc """
  Creates a activity_type.

  ## Examples

      iex> create_activity_type(%{field: value})
      {:ok, %ActivityType{}}

      iex> create_activity_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity_type(attrs \\ %{}) do
    %ActivityType{}
    |> ActivityType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity_type.

  ## Examples

      iex> update_activity_type(activity_type, %{field: new_value})
      {:ok, %ActivityType{}}

      iex> update_activity_type(activity_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity_type(%ActivityType{} = activity_type, attrs) do
    activity_type
    |> ActivityType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity_type.

  ## Examples

      iex> delete_activity_type(activity_type)
      {:ok, %ActivityType{}}

      iex> delete_activity_type(activity_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity_type(%ActivityType{} = activity_type) do
    Repo.delete(activity_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity_type changes.

  ## Examples

      iex> change_activity_type(activity_type)
      %Ecto.Changeset{data: %ActivityType{}}

  """
  def change_activity_type(%ActivityType{} = activity_type, attrs \\ %{}) do
    ActivityType.changeset(activity_type, attrs)
  end
end
