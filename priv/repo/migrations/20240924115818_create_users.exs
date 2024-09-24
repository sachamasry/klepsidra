defmodule Klepsidra.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users,
             primary_key: false,
             comment: "Users are entities who are authorised to log in to and use the system"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based system user primary key"

      add :user_name, :string,
        null: false,
        comment: "The user's user name on the system; this is not their actual or display name"

      add :login_email, :string,
        null: false,
        comment:
          "The email address used to log the user into the system; this is only used for logging purposes, and doesn't need to be their preferred communication email address"

      add :password_hash, :string,
        null: false,
        comment: "This is a hash of the user's plaintext password"

      add :description, :text,
        comment: "Any other details about the user which may be useful in future"

      add :frozen, :boolean,
        default: false,
        null: false,
        comment: "Is this user 'frozen' out of further system access?"

      add :active, :boolean,
        default: true,
        null: false,
        comment: "Is this user still active and authorised to log in to the system?"

      timestamps()
    end

    create unique_index(:users, [:user_name],
             unique: true,
             comment: "Unique index on `user_name`"
           )

    create unique_index(:users, [:login_email],
             unique: true,
             comment: "Unique index on `login_email`"
           )

    create index(:users, [:frozen], comment: "Index of user `frozen` flag field")

    create index(:users, [:active], comment: "Index of user `active` flag field")
  end
end
