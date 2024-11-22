defmodule Klepsidra.Documents.DocumentType do
  @moduledoc """
  Defines the `DocumentTypes` schema and functions needed to classify 
  documents by type.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t(),
          default_validity_period_unit: String.t(),
          default_validity_duration: integer(),
          notification_lead_time_days: integer(),
          processing_time_estimate_days: integer(),
          default_buffer_time_days: integer(),
          is_country_specific: boolean(),
          requires_renewal: boolean()
        }
  schema "document_types" do
    field :name, :string
    field :description, :string
    field :default_validity_period_unit, :string
    field :default_validity_duration, :integer
    field :notification_lead_time_days, :integer
    field :processing_time_estimate_days, :integer
    field :default_buffer_time_days, :integer
    field :is_country_specific, :boolean
    field :requires_renewal, :boolean

    timestamps()
  end

  @doc false
  def changeset(document_type, attrs) do
    document_type
    |> cast(attrs, [
      :name,
      :description,
      :default_validity_period_unit,
      :default_validity_duration,
      :notification_lead_time_days,
      :processing_time_estimate_days,
      :default_buffer_time_days,
      :is_country_specific,
      :requires_renewal
    ])
    |> validate_required([
      :name,
      :default_validity_period_unit,
      :default_validity_duration,
      :notification_lead_time_days,
      :processing_time_estimate_days,
      :default_buffer_time_days,
      :is_country_specific,
      :requires_renewal
    ])
    |> unique_constraint(:name,
      message: "A document type with this name already exists"
    )
  end
end
