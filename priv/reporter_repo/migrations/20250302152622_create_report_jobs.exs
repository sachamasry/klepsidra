defmodule Klepsidra.ReporterRepo.Migrations.CreateReportJobs do
  use Ecto.Migration

  def change do
    create table(:report_jobs,
             primary_key: false,
             comment:
               "Report jobs represent reports that have been requested and placed in a queue, for asynchronous generation."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based report job primary key"

      add :state, :string,
        default: "available",
        null: false,
        comment:
          "The current job state. All jobs will start life with a state of 'available' and will be updated to 'completed' once the report has been successfully generated. The following is a valid (and ordered) list of all accepted states: 'scheduled', 'available', 'executing', 'retryable', 'completed', 'discarded', and 'cancelled'."

      add :report_name, :string,
        null: false,
        comment: "Unique human-formatted name for the requested report"

      add :system_report_name, :string,
        null: false,
        comment: "Unique system name for the requested report"

      add :report_template_name, :string,
        null: false,
        comment: "Unique human-formatted name for the requested report template"

      add :report_version, :integer,
        default: 0,
        comment:
          "Report version, used for cache invalidation, incremented when (a) the report template or logic has been updated; (b) when the shape or format of the data has been modified; and (c) any bug fixes or improvements have been made to the report generation code"

      add :template_path, :string,
        null: false,
        comment:
          "Absolute path to the `.jrxml` template file of the requested report template (multiple distinct template layouts can exist for each report type)"

      add :parameter_fingerprint, :string,
        default: "",
        null: false,
        comment:
          "The parameter fingerprint is a hash of the full set of unique report parameters and input dataset, uniquely identifying each requested report. The fingerprint improves performance, as reports which are computationally expensive to produce can simply be fetched from the queue, in situations where the parameter fingerprint matches."

      add :parameters_and_data, :map,
        default: %{},
        null: false,
        comment:
          "Record of the full input parameters, and input dataset used in the generation of this report, encoded in JSON format, data which will be used for generating the finished report"

      add :temporary_tables_created, :map,
        default: %{},
        null: false,
        comment:
          "Record of all temporary tables created during the generation of the report, for data reference and later temporary table deletion"

      add :output_path, :string,
        null: false,
        comment: "Absolute path where the generated report will be saved"

      add :output_filename, :string,
        null: false,
        comment: "The desired output file name for the generated report"

      add :output_type, :string,
        null: false,
        default: "pdf",
        comment: "Selects the desired output file format"

      add :errors, :map,
        default: %{},
        null: false,
        comment: "Records errors encountered in the production of the report"

      add :meta, :map,
        default: %{},
        null: false,
        comment: "Records any relevant metadata relevant to the production of the report"

      add :attempt, :integer,
        default: 0,
        null: false,
        comment: "Which attempt at generating the report is this (zero-indexed counter)?"

      add :max_attempts, :integer,
        default: 3,
        null: false,
        comment:
          "How many attempts should the system make to generate this report (zero-indexed counter)?"

      add :priority, :integer,
        default: 0,
        null: false,
        comment:
          "What is this report's priority? Zero indicates no priority, the higher the number, the more urgent the generation of this report. After report generation, the priority acts as a cache bias, acting as an importance level for cache retention policies, where high-priority cached reports are kept in storage for longer. Reports that are expensive to generate can be assigned higher priority to avoid regeneration, and where frequently accessed reports can have their priority automatically increased"

      add :result_path, :string,
        default: "",
        null: false,
        comment: "The full path of the completed report file"

      add :generation_time_ms, :integer,
        default: 0,
        null: false,
        comment: "Indicates the time taken to generate the report (in milliseconds)"

      timestamps()

      add :scheduled_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was scheduled"

      add :attempted_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was last attempted"

      add :attempted_by, :map,
        default: %{},
        null: false,
        comment:
          "Audit trail of the user, node and any other distinction to process, application or subsystem requesting the report"

      add :cancelled_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was cancelled"

      add :completed_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was finally successfully completed"

      add :discarded_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was discarded"

      add :cache_expires_at, :utc_datetime,
        default: "",
        null: false,
        comment: "Optional cached report validity expiry date for date-based cache invalidation"

      add :cache_hits, :integer,
        default: 0,
        comment: "Counter tracking how many times this cached report was used"

      add :cache_is_valid, :boolean,
        default: true,
        commens: "Manual cache invalidation flag"

      add :cache_invalidation_reason, :map,
        default: %{},
        comment: "Reason why this cached report was invalidated"

      add :cache_last_accessed_at, :utc_datetime,
        default: "",
        null: false,
        comment:
          "When was this cached report was last used? Helps with the cleanup of unused cached reports"
    end

    create unique_index(
             :report_jobs,
             [
               :report_name,
               :system_report_name,
               :report_template_name,
               :output_type,
               :report_version,
               :parameter_fingerprint,
               :scheduled_at
             ],
             comment:
               "Composite unique index of `report_name`, `system_report_name`, `report_template_name`, `output_type`, `report_version`, `parameter_fingerprint`, and `scheduled_at` fields."
           )

    create index(:report_jobs, :report_name, comment: "Index of queued report name")
    create index(:report_jobs, :system_report_name, comment: "Index of queued report system name")
    create index(:report_jobs, :report_version, comment: "Index of report version")
    create index(:report_jobs, :output_type, comment: "Index of report output type")

    create index(:report_jobs, :state,
             comment: "Index of job queue state, for easy retrieval, ordering and search"
           )

    create index(:report_jobs, :parameter_fingerprint,
             comment:
               "Index of report parameter 'fingerprint' improving speed of retrieval of identical jobs"
           )

    create index(:report_jobs, :priority, comment: "Index of job priority")

    create index(:report_jobs, :output_path,
             comment: "Index of job by generated report output file path"
           )

    create index(:report_jobs, :inserted_at,
             comment: "Index of job by `inserted_at` datetime stamp"
           )

    create index(:report_jobs, :scheduled_at,
             comment: "Index of job by `scheduled_at` datetime stamp"
           )

    create index(:report_jobs, :cache_expires_at,
             comment: "Index of job by `cache_expires_at` datetime stamp"
           )

    create index(:report_jobs, :cache_hits,
             comment: "Index of job by `cache_hits` cache access counter"
           )

    create index(:report_jobs, :cache_is_valid,
             comment: "Index of job by `cache_is_valid` cache validity flag"
           )

    create index(:report_jobs, :cache_last_accessed_at,
             comment: "Index of job by `cache_last_accessed` cache use recency datetime stamp"
           )
  end
end
