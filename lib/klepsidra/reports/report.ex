defmodule Klepsidra.Reports.Report do
  @moduledoc """
  Defines a schema for the `Report` entity, a register of all reports the
  application has been developed to produce.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          report_name: String.t(),
          system_report_name: String.t(),
          template_variant_name: String.t(),
          system_template_name: String.t(),
          template_path: String.t(),
          description: String.t(),
          output_type: atom(),
          output_filename_template: String.t(),
          is_system_managed: boolean()
        }
  schema "reports" do
    field :report_name, :string
    field :system_report_name, :string
    field :template_variant_name, :string
    field :system_template_name, :string
    field :template_path, :string
    field :description, :string

    field :output_type, Ecto.Enum,
          values: [:pdf, :html, :rtf, :txt, :csv, :json, :xlsx, :docx, :pptx, :odt, :ods]

    field :output_filename_template, :string
    field :is_system_managed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [
      :report_name,
      :system_report_name,
      :template_variant_name,
      :system_template_name,
      :template_path,
      :description,
      :output_type,
      :output_filename_template,
      :is_system_managed
    ])
    |> validate_required([
      :report_name,
      :system_report_name,
      :template_variant_name,
      :template_path,
      :output_type,
      :output_filename_template
    ])
  end
end
