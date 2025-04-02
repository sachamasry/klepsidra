defmodule Klepsidra.Utilities.FilesystemUtilities do
  @moduledoc """
  This module simplifies interfacing with the filesystem, providing commonly
  expected utilities such as getting file modification times, sizes, checking
  for file existence, etc.
  """

  @doc """
  Returns a file's last modified datetime stamp.

  ## Notes

  Erlang’s :calendar.datetime_to_gregorian_seconds/1 counts seconds from year 0,
  whereas Unix timestamps count from 1970-01-01.

  Erlang’s Gregorian epoch begins on 0000-01-01 00:00:00 UTC, so 62_167_219_200 is
  the number of seconds between this epoch and that of Unix. Thus, the function
  subtracts this number from its answer to bring it portably in line with
  other utilities using the Unix time epoch.
  """
  @spec get_file_last_modified_stamp(file_path :: String.t()) :: integer()
  def get_file_last_modified_stamp(file_path) do
    case File.stat(file_path) do
      {:ok, %File.Stat{mtime: mtime}} ->
        :calendar.datetime_to_gregorian_seconds(mtime) - 62_167_219_200

      {:error, reason} ->
        {:error, reason}
    end
  end
end
