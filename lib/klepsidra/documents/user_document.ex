defmodule Klepsidra.Documents.UserDocument do
  @moduledoc """
  Defines the `user_documents` schema needed to record important or legal
  user documents, which are private, possessing a distinct validity period.

  The system can monitor these documents and raise notifications of their
  expiry, giving ample time for action.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          document_type_id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          unique_reference: String.t(),
          issued_by: String.t(),
          issuing_country_id: String.t(),
          issue_date: NaiveDateTime.t(),
          expiry_date: NaiveDateTime.t(),
          is_active: boolean(),
          file_url: String.t()
          }
  schema "user_documents" do
    field :document_type_id, Ecto.UUID
    field :user_id, Ecto.UUID
    field :unique_reference, :string
    field :issued_by, :string
    field :issuing_country_id, :string
    field :issue_date, :date
    field :expiry_date, :date
    field :is_active, :boolean, default: false
    field :file_url, :string

    timestamps()
  end

  @doc false
  def changeset(user_document, attrs) do
    user_document
    |> cast(attrs, [:document_type_id, :user_id, :unique_reference, :issued_by, :issuing_country_id, :issue_date, :expiry_date, :is_active, :file_url])
    |> validate_required([:document_type_id, :user_id, :unique_reference, :issued_by, :issuing_country_id, :issue_date, :expiry_date, :is_active])
  end
end
