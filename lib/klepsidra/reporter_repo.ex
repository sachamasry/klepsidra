defmodule Klepsidra.ReporterRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :klepsidra,
    adapter: Ecto.Adapters.SQLite3
end
