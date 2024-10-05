# Klepsidra

Time your activities to bill clients, and understand where your time goes.

## Overview

Klepsidra is an activity timer for freelance service providers, agencies,
developers, and others providing services quoted and billed in time taken. Use
it to time activities, for internal use and analysis, and for client billings.

## Setup & Installation

Install Elixir, clone this repository, then change into its directory.

To start your Phoenix server:

* Run `mix setup` to installalhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment
guides](https://hexdocs.pm/phoenix/deployment.html).

## To do

### MVP: Make application self-hosting

* UI/UX
  * Develop aggregate time display function component, to pleasingly display
    * aggregate time recorded, in hours
    * human-formatted days/hours/minutes
    * number of timers recorded
  * Display tags for open and closed timers
  * Report on aggregate time spent, or timed, by tag, reporting on tag _show_
    page
  * Report on aggregate time spent by activity type, reporting on activity_type
    show page
  * Report on aggregate time spent by tag, reporting on tag show page
  * Restyle timer listings, giving more visual value to the time recorded,
    rather than the times the timer was started and stopped

* Ensure a second warning message is displayed to the user, ensuring
  they truly understand the impact of deleting the timer
  * Look for good UX examples, as this is likely to become a UX
    annoyance, more than a saviour of data loss

* Implement a 'today' view
  * Provide daily navigation facility: back, forward and today
  * Update timer listings
    * Add timer tags

* UI improvements
  * Calculate average time spent across timed sessions


### Future

* Create new feature, recording time spent in economic territories/countries,
  for nomads, showing how close to limit they are, according to the prevailing
  legislation
* Provide way to 'deactivate' old tags
* Start creating an undo feature, reducing reliance on confirmation dialogs,
  particularly for deletions
      * Build an audit trail-like functionality, to be able to undo any deletion
        or modification, at any time, as well as to see a history of actions
        taken
* Document truncate and markdown_to_html functions
* Audit other timers for strengths and weaknesses
* Markdown
  * Refactor conversion of plain text to Markdown everywhere; should
    interpretation happen at table layout level, or earlier at query level?
  * Create a dedicated field to markdown text, and another for HTML, to improve
    performance, by not requiring just in time mardown interpretation
* Expand role of activity types beyond the hour rate, to act as a rigid
  categorisation for major types of activities, which cannot be entrusted to
  tags only, e.g. exercise, learning, professional development
  * Automate `billable`, duration unit measurements, and tags within it;
    selecting this on an activity should automatically adjust these attributes
    on a timer
* Security improvements
  * Improve handling of `return_to` functionality
    * Ensure it is a validated route at point of sending
    * Ensure the parameter is read at the `router.ex` level
    * Send the information through to the target in an `on_mount` function
    * Remove the parameter and clean up the URL, redirecting to it, before the
      user can see it, in case they want to bookmark the page
      (https://elixirforum.com/t/how-to-store-return-to-url-when-navigating-from-liveview-to-another-page-liveview-regular/55480/4)
    * Insert it in the render code, as a verified route
* UI improvements
  * Calculate duration of open timers, updating regularly?
  * Replace timer listing description pop-up (title attribute), with a proper
    HTML-formatted popover component
  * Incorporate Gov.uk Design System (https://design-system.service.gov.uk/)
    accessibility and user interface/experience decisions, starting from input
    controls
  * Allow stopping a timer from timer 'show' view
  * Select a UI component framework, to aid in the building of a modern web app
  * Improve on cryptic or incomplete UI error messages
  * Resize datetime, duration and duration unit controls to more efficiently use
    space
  * Start implementing colour palette
  * Improve presentation of currency fields; at present they use an input
    control of type 'number' which is unintuitive UX
  * On timer note timeline, next to the `created_on` date, display the
    `updated_on` date in a visually highlighted way, showing that a note was
    edited and when
  * Advanced timer reports filters:
    * tags
* Tagging UX improvements
  * Make it possible to drill into the tag from the live component
  * Provide ability to set new tag colour when creating freeform tag in live
    component
  * Document tag selector live component
  * Improve search functionality to perform fuzzy query directly in the database
  * Develop ability to cope with temporary data structures, before a timer has
    been created?
* General UX inmprovements
  * Permit pausing and resuming timers; add forward-pointing field to next
    timer, like a linked list
* Look into default `timestamps()` fields; it appears that datetime stamps are
  in UTC, where local timezone may be preferable
  * Specifically for timestamps recorded for notes
* Full-text search
  * Create a full-text tag search
  * Begin adding keyboard shortcuts for an improved user interface
  * Enable SQLite notes field full-text search
  * Start enabling full-text search on other relevant database fields
* Reformat listing display to a more useful format, removing description field
  to a popup box or tooltip; change date display to more informative format

### One day

* Break down and list all ultimate desiderata for an activity timer

### Tests

* Test on month-first locales
* Test on 12-hour clock locales
* Do all browsers return a 'T' delimited datetime-local stamp? Do both delimiters need to be handled? According to the standard, yes

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
