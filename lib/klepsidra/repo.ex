defmodule Klepsidra.Repo do
  use Ecto.Repo,
    otp_app: :klepsidra,
    adapter: Ecto.Adapters.SQLite3
end
