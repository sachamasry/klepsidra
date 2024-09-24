defmodule Klepsidra.Accounts.User do
  @moduledoc """
  Define a schema for the `User` entity, recording authorised system users,
  for authorisation, ownership, auditing and logging purposes.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          user_name: String.t(),
          login_email: String.t(),
          password_hash: String.t(),
          description: String.t(),
          frozen: boolean(),
          active: boolean()
        }
  schema "users" do
    field :user_name, :string
    field :login_email, :string
    field :password_hash, :string
    field :description, :string
    field :frozen, :boolean, default: false
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_name, :login_email, :password_hash, :frozen, :active])
    |> validate_required([:user_name, :login_email, :password_hash])
    |> unique_constraint(:user_name,
      name: :users_user_name_index,
      message: "This user name is taken"
    )
    |> unique_constraint(:login_email,
      name: :users_login_email_index,
      message: "This login email has already been registered"
    )
  end
end
