defmodule Klepsidra.Documents.UserDocument do
  @moduledoc """
  Defines the `user_documents` schema needed to record important or legal
  user documents, which are private to the user and posses a distinct
  validity period.

  The system can monitor these documents and raise notifications of their
  expiry, giving ample time for action.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Klepsidra.Locations.Country
  alias Klepsidra.Accounts.User
  alias Klepsidra.Documents.DocumentType
  alias Klepsidra.Documents.DocumentIssuer

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          document_type_id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          country_id: String.t(),
          document_issuer_id: Ecto.UUID.t(),
          unique_reference_number: String.t(),
          name: String.t(),
          description: String.t(),
          issued_at: Date.t(),
          expires_at: Date.t(),
          is_active: boolean(),
          invalidation_reason: String.t(),
          file_url: String.t(),
          custom_buffer_time_days: integer()
        }
  schema "user_documents" do
    belongs_to(:document_types, DocumentType, foreign_key: :document_type_id, type: Ecto.UUID)

    belongs_to(:users, User, foreign_key: :user_id, type: Ecto.UUID)

    belongs_to(:locations_countries, Country,
      foreign_key: :country_id,
      references: :iso_3_country_code,
      type: :string
    )

    belongs_to(:document_issuers, DocumentIssuer,
      foreign_key: :document_issuer_id,
      type: Ecto.UUID
    )

    field :unique_reference_number, :string
    field :name, :string
    field :description, :string
    field :issued_at, :date
    field :expires_at, :date
    field :is_active, :boolean, default: true
    field :invalidation_reason, :string
    field :file_url, :string
    field :custom_buffer_time_days, :integer

    timestamps()
  end

  @doc false
  def changeset(user_document, attrs) do
    user_document
    |> cast(attrs, [
      :document_type_id,
      :user_id,
      :country_id,
      :document_issuer_id,
      :unique_reference_number,
      :name,
      :description,
      :issued_at,
      :expires_at,
      :is_active,
      :invalidation_reason,
      :file_url,
      :custom_buffer_time_days
    ])
    |> validate_required([:document_type_id], message: "What type of document is this?")
    |> validate_required([:user_id], message: "Whose document is this?")
    |> validate_required([:unique_reference_number],
      message: "Enter the document's unique reference or serial nmber"
    )
    |> validate_required([:is_active],
      message: "Is this document currently valid or not?"
    )
    |> unique_constraint(:unique_reference_number,
      message: "This unique reference number has already been used"
    )
  end
end
