defmodule Klepsidra.Utilities.Benchmarking do
  @moduledoc "Benchmarking SHA-256 vs BLAKE2 using Erlang's :crypto module"

  alias Klepsidra.Utilities.HashFunctions

  # 1MB of random data
  @test_data :crypto.strong_rand_bytes(1_000_000)

  def run(file_path) do
    file_data = HashFunctions.read_file!(file_path)

    Benchee.run(
      %{
        "SHA-256 (:crypto)" => fn -> HashFunctions.hash_sha256(file_data) end,
        "BLAKE2 (:crypto)" => fn -> HashFunctions.hash_blake2(file_data) end
      },
      time: 5,
      # memory_time: 2,
      parallel: 4
    )
  end
end
