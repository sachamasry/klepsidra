defmodule Klepsidra.Utilities.HashFunctions do
  @moduledoc """
  This module simplifies interfacing to Erlang's `:crypto` module, providing string hashing functions, for _fingerprinting_ purposes.
  """

  @doc """
  Takes a message, hashing it with the [BLAKE2b](https://www.blake2.net/)
  hashing function, encoding the resultant binary into a base-16 encoded
  lowercased string, with no padding.

  The message, passed through the `data` parameter, can be a string or map.

  ## Examples

  		iex> compute_hash("Hello, world!")
  		"a2764d133a16816b5847a737a786f2ece4c148095c5faa73e24b4cc5d666c3e45ec271504e14dc6127ddfce4e144fb23b91a6f7b04b53d695502290722953b0f"

  		iex> compute_hash(%{key: "value"})
  		"8859ef88bbc5a0f858d0971364d9c70d93186e6c4b5655833f18a17e750c7558ac7f7cd4c48a86f279f33a5bb3635a11b23642f016ab58d4d8f4457a20110525"

  		iex> compute_hash()
  		** (UndefinedFunctionError)
  """
  @spec compute_hash(message :: binary() | map()) :: binary()
  def compute_hash(message) when is_bitstring(message) do
    :crypto.hash(:blake2b, message)
    |> Base.encode16(padding: false, case: :lower)
  end

  def compute_hash(message) when is_map(message) do
    :crypto.hash(:blake2b, :erlang.term_to_binary(message))
    |> Base.encode16(padding: false, case: :lower)
  end

  def read_file!(path) do
    File.read!(path)
  end

  def hash_sha256(data) do
    :crypto.hash(:sha256, data)
  end

  def hash_blake2(data) do
    :crypto.hash(:blake2b, data)
  end
end
