defmodule Klepsidra.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Klepsidra.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        login_email: "some login_email",
        password_hash: "some password_hash",
        user_name: "some user_name"
      })
      |> Klepsidra.Accounts.create_user()

    user
  end
end
