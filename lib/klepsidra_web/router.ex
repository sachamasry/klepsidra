defmodule KlepsidraWeb.Router do
  use KlepsidraWeb, :router

  @moduledoc false

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash

    plug :put_root_layout,
      html: {KlepsidraWeb.Layouts, :root}

    plug :protect_from_forgery

    plug :put_content_security_policy,
      default_src: "'none'",
      script_src: "'self' 'nonce'",
      style_src: "'self' 'nonce'",
      connect_src: "'self'",
      img_src: "'self' data:",
      font_src: "'self'",
      frame_src: "'self' 'nonce'"

    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KlepsidraWeb do
    pipe_through :browser

    live "/", StartPageLive
    live "/start_timer", StartPageLive, :start_timer
    live "/stop_timer/:id", StartPageLive, :stop_timer
    live "/new_timer", StartPageLive, :new_timer
    live "/timer_notes/:id/notes/new", StartPageLive, :new_note
    live "/edit_timer/:id", StartPageLive, :edit_timer

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    live "/tags", TagLive.Index, :index
    live "/tags/new", TagLive.Index, :new
    live "/tags/:id/edit", TagLive.Index, :edit

    live "/tags/:id", TagLive.Show, :show
    live "/tags/:id/show/edit", TagLive.Show, :edit

    live "/timers", TimerLive.Index, :index
    live "/timers/new", TimerLive.Index, :new_timer
    live "/timers/start", TimerLive.Index, :start_timer
    live "/timers/:id/edit", TimerLive.Index, :edit_timer
    live "/timers/:id/stop", TimerLive.Index, :stop_timer
    live "/timers/:id/notes/new", TimerLive.Index, :new_note

    live "/timers/:id", TimerLive.Show, :show
    live "/timers/:id/stop-timer", TimerLive.Show, :stop_timer
    live "/timers/:id/new-note", TimerLive.Show, :new_note
    live "/timers/:id/notes/:note_id/edit", TimerLive.Show, :edit_note
    live "/timers/:id/show/edit", TimerLive.Show, :edit_timer

    live "/activity_types", ActivityTypeLive.Index, :index
    live "/activity_types/new", ActivityTypeLive.Index, :new
    live "/activity_types/:id/edit", ActivityTypeLive.Index, :edit

    live "/activity_types/:id", ActivityTypeLive.Show, :show
    live "/activity_types/:id/show/edit", ActivityTypeLive.Show, :edit

    live "/notes", NoteLive.Index, :index
    live "/notes/new", NoteLive.Index, :new
    live "/notes/:id/edit", NoteLive.Index, :edit

    live "/notes/:id", NoteLive.Show, :show
    live "/notes/:id/show/edit", NoteLive.Show, :edit

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id/edit", ProjectLive.Index, :edit

    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/show/edit", ProjectLive.Show, :edit

    live "/customers", BusinessPartnerLive.Index, :index
    live "/customers/new", BusinessPartnerLive.Index, :new
    live "/customers/:id/edit", BusinessPartnerLive.Index, :edit

    live "/customers/:id", BusinessPartnerLive.Show, :show
    live "/customers/:id/show/edit", BusinessPartnerLive.Show, :edit

    live "/journal_entry_types", JournalEntryTypesLive.Index, :index
    live "/journal_entry_types/new", JournalEntryTypesLive.Index, :new
    live "/journal_entry_types/:id/edit", JournalEntryTypesLive.Index, :edit

    live "/journal_entry_types/:id", JournalEntryTypesLive.Show, :show
    live "/journal_entry_types/:id/show/edit", JournalEntryTypesLive.Show, :edit

    live "/journal_entries", JournalEntryLive.Index, :index
    live "/journal_entries/new", JournalEntryLive.Index, :new
    live "/journal_entries/:id/edit", JournalEntryLive.Index, :edit

    live "/journal_entries/:id", JournalEntryLive.Show, :show
    live "/journal_entries/:id/show/edit", JournalEntryLive.Show, :edit

    live "/annotations", AnnotationLive.Index, :index
    live "/annotations/new", AnnotationLive.Index, :new
    live "/annotations/:id/edit", AnnotationLive.Index, :edit

    live "/annotations/:id", AnnotationLive.Show, :show
    live "/annotations/:id/show/edit", AnnotationLive.Show, :edit

    live "/reporting/activities_timed", TimerLive.ActivityTimeReporting, :index

    live "/reporting/activities_timed/timers/:id/edit",
         TimerLive.ActivityTimeReporting,
         :edit_timer

    live "/document_types", DocumentTypeLive.Index, :index
    live "/document_types/new", DocumentTypeLive.Index, :new
    live "/document_types/:id/edit", DocumentTypeLive.Index, :edit

    live "/document_types/:id", DocumentTypeLive.Show, :show
    live "/document_types/:id/show/edit", DocumentTypeLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", KlepsidraWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:klepsidra, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KlepsidraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
