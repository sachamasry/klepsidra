defmodule Klepsidra.Repo.Migrations.CreateTimers do
  use Ecto.Migration

  def change do
    create table(:timers,
             primary_key: false,
             comment:
               "Activity timers record all relevant information about the time taken working on an activity. Activities can be closed-ended, such as timing of project tasks, or can be open-ended for regular and indefinite activities, aiding time tracking and analysis"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based activity timer primary key"

      add :start_stamp, :string,
        comment:
          "ISO 8601 Extended-formatted datetime stamp (YYYY-MM-DD HH:mm:ss) indicating activity start time"

      add :end_stamp, :string,
        comment:
          "ISO 8601 Extended-formatted datetime stamp (YYYY-MM-DD HH:mm:ss) indicating activity end time"

      add :duration, :integer,
        comment:
          "Calculated timer duration, denominated in `duration_time_unit` time increments, rounded up to the nearest integer. Used for analysis of actual time taken completing the activity"

      add :duration_time_unit, :string,
        comment: "Duration time increment, used to denominate `duration` timer duration"

      add :billable, :boolean,
        default: false,
        null: false,
        comment: "Is this activity billable to the customer?"

      add :business_partner_id, references(:business_partners, on_delete: :nothing, type: :uuid),
        comment:
          "Foreign key pointing at the customer (business partner) to be billed for this activity"

      add :activity_type_id, references(:activity_types, on_delete: :nothing, type: :uuid),
        comment:
          "Foreign key pointing at `activity_types`, where default billing rates have been defined for different types of activities"

      add :billing_rate, :decimal,
        comment:
          "Billing rate for the timed activity, defined per complete hour of time taken. Assumed to be in the organisation's default currency. By default, fed from the choice of `activity_type_id`, manually overridable for each timed activity"

      add :billing_duration, :integer,
        comment:
          "Calculated timer billing duration, denominated in `billing_duration_time_unit` time increments, rounded up to the nearest integer. Used for customer billing of actual time taken completing the activity"

      add :billing_duration_time_unit, :string,
        comment: "Duration time increment, used to denominate `duration` timer duration"

      add :description, :text,
        comment:
          "Official descriptio of work caried out. This description will be used in timesheets, invoices and any other legal documents and reports"

      add :project_id, references(:projects, on_delete: :nothing, type: :uuid),
        comment: "Foreign key linking the activity to a project"

      timestamps()
    end

    create unique_index(:timers, [:start_stamp],
             comment: "Index with the project `start_stamp` as the main indexed key"
           )
  end
end
