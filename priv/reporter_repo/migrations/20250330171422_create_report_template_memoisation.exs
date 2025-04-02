defmodule Klepsidra.ReporterRepo.Migrations.CreateReportTemplateMemoisation do
  use Ecto.Migration

  def change do
    create table(:report_templates_memoisation,
             primary_key: false,
             comment:
               "Report templates is a memoisation table, storing compiled report templates, removing the need to [expensively] compile report templates at every report generation."
           ) do
      add :template_path, :string,
        primary_key: true,
        null: false,
        comment:
          "Absolute report template path-based primary key. Each unique report variant will be backed by precisely one report template, located at a necessarily unique file path, making it a good primary key candidate."

      add :template_file_last_modified, :utc_datetime_usec,
        null: false,
        comment:
          "Template file's last modified datetime stamp, down to the microsecond level of detail. A primary check for template changes, if the last modified stamp is the same, then the hash function doesn't need be invoked, saving processing resources."

      add :template_file_hash, :string,
        null: false,
        comment:
          "Unique SHA-256 hash of the report template file. If the current file hash maches the recorded hash, then use the memoised compiled template, preventing an expensive (half-second and above) template file compilation."

      add :compiled_report_template, :binary,
        null: false,
        comment: "Binary BLOB field, storing the in-memory compiled report template."

      timestamps()
    end
  end
end
