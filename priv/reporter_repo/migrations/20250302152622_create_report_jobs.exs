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

      add :report_name, :string,
        null: false,
        comment: "Unique system name for the requested report"

      add :report_template, :string,
        null: false,
        comment:
          "Reference to the file name of the requested report template (multiple distinct template layouts can exist for each report type)"

      add :output_format, :string,
        default: "pdf",
        null: false,
        comment: "Selects the desired output file format"

      add :state, :string,
        default: "pending",
        null: false,
        comment:
          "The current job state. All jobs will start life with a state of 'pending' and will be updated to 'complete' once the job has been generated. Other states include 'cancelled' and 'discarded'."

      add :report_fingerprint, :string,
        default: "",
        null: false,
        comment:
          "The report fingerprint is a hash of the full set of unique report criteria, used to uniquely identify each report. The fingerprint improves performance, as reports which are computationally expensive to produce can simply be fetched from the queue, in situations where the fingerprint matches."

      add :parameters, :map,
        default: %{},
        null: false,
        comment:
          "This field records the full dataset used in the generation of this report, encoded in JSON format, data which will be used for generating the finished report"

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
          "What is this report's priority? Zero indicates no priority, the higher the number, the more urgent the generation of this report."

      add :result_path, :string,
        default: "",
        null: false,
        comment: "The full path of the completed report file"

      timestamps()

      add :scheduled_at, :string,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was scheduled"

      add :attempted_at, :string,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was last attempted"

      add :attempted_by, :map,
        default: %{},
        null: false,
        comment:
          "Audit trail of the user, node and any other distinction to process, application or subsystem requesting the report"

      add :cancelled_at, :string,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was cancelled"

      add :completed_at, :string,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was finally successfully completed"

      add :discarded_at, :string,
        default: "",
        null: false,
        comment: "Timestamp specifying when the report job was discarded"
    end

    create unique_index(
             :report_jobs,
             [:report_name, :report_template, :output_format, :report_fingerprint, :scheduled_at],
             comment:
               "Composite unique index of `report_name`, `report_template`, `output_format`, `report_fingerprint` and `scheduled_at` fields."
           )

    create index(:report_jobs, :report_name, comment: "Index of queued report type")
    create index(:report_jobs, :output_format, comment: "Index of output format type")

    create index(:report_jobs, :state,
             comment: "Index of job queue state, for easy retrieval, ordering and search"
           )

    create index(:report_jobs, :report_fingerprint,
             comment:
               "Index of report 'fingerpring' improving speed of retrieval of identical jobs"
           )

    create index(:report_jobs, :priority, comment: "Index of job priority")

    create index(:report_jobs, :result_path,
             comment: "Index of job by generated report file path"
           )

    create index(:report_jobs, :inserted_at,
             comment: "Index of job by `inserted_at` datetime stamp"
           )

    create index(:report_jobs, :scheduled_at,
             comment: "Index of job by `scheduled_at` datetime stamp"
           )
  end
end
