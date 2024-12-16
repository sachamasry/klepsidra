defmodule Klepsidra.Repo.Migrations.CreateUnifiedSearchView do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIEW IF NOT EXISTS unified_search_view AS
    SELECT
    rowid,
    entity_id,
    entity,
    category,
    status,
    owner_id,
    group_id,
    title,
    subtitle,
    author,
    tags,
    location,
    text,
    inserted_at,
    updated_at
    FROM
    (
    -- Annotations
    SELECT
    rowid AS rowid,
    id AS entity_id,
    'annotation' AS entity,
    CASE
    entry_type
     	WHEN 'anotation' THEN 'Annotation'
    WHEN 'quote' THEN 'Quote'
    END
     AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    NULL AS title,
    NULL AS subtitle,
    author_name AS author,
    NULL AS tags,
    NULL AS location,
    concat(text, ' · ', comment, ' · ', position_reference) AS text,
    inserted_at,
    updated_at
    FROM
    annotations a
    UNION ALL
    -- Business partner notes
    SELECT
    bpn.rowid + 1_000_000_000_000 AS rowid,
    bpn.id AS entity_id,
    'business_partner_note' AS entity,
    CASE
    WHEN bp.customer THEN 'Customer note'
    WHEN bp.supplier THEN 'Supplier note'
    END AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    bp.name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    note AS text,
    bpn.inserted_at,
    bpn.updated_at
    FROM
    business_partner_notes bpn
    LEFT JOIN business_partners bp
    ON
    bpn.business_partner_id = bp.id
    UNION ALL
    -- Business partners
    SELECT
    rowid + 2_000_000_000_000 AS rowid,
    id AS entity_id,
    'business_partner' AS entity,
    CASE
    WHEN customer THEN 'Customer'
    WHEN supplier THEN 'Supplier'
    END AS category,
    CASE
    WHEN frozen THEN 'Frozen'
    WHEN active THEN 'Active'
    ELSE 'Inactive'
    END AS status,
    NULL AS owner_id,
    NULL AS group_id,
    name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    NULL AS text,
    inserted_at,
    updated_at
    FROM
    business_partners bp
    UNION ALL
    -- Document issuers
    SELECT
    di.rowid + 3_000_000_000_000 AS rowid,
    di.id AS entity_id,
    'document_issuer' AS entity,
    'Document issuer' AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    di.name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    lc.country_name AS location,
    concat(di.description, ' · ', di.contact_information, ' · ', di.website_url) AS text,
    di.inserted_at,
    di.updated_at
    FROM
    document_issuers di
    LEFT JOIN locations_countries lc
    ON
    di.country_id = lc.iso_3_country_code
    UNION ALL
    -- Document types
    SELECT
    rowid + 4_000_000_000_000 AS rowid,
    id AS entity_id,
    'document_type' AS entity,
    'Document type' AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    description AS text,
    inserted_at,
    updated_at
    FROM
    document_types dt
    UNION ALL
    -- Journal entries
    SELECT
    je.rowid + 5_000_000_000_000 AS rowid,
    je.id AS entity_id,
    'journal_entry' AS entity,
    jety.name AS category,
    NULL AS status,
    je.user_id AS owner_id,
    NULL AS group_id,
    je.highlights AS title,
    NULL AS subtitle,
    u.user_name AS author,
    GROUP_CONCAT(t.name, ' · ') AS tags,
    lc.name AS location,
    je.entry_text_markdown AS text,
    je.inserted_at,
    je.updated_at
    FROM
    journal_entries je
    LEFT JOIN journal_entry_types jety
    ON
    je.entry_type_id = jety.id
    LEFT JOIN journal_entry_tags jet
    ON
    je.id = jet.journal_entry_id
    LEFT JOIN tags t
    ON
    jet.tag_id = t.id
    LEFT JOIN locations_cities lc
    ON je.location_id = lc.id
    LEFT JOIN users u
    ON je.user_id = u.id
    WHERE
    je.is_private = 0
    GROUP BY entity_id
    UNION ALL
    -- Journal entry types
    SELECT
    rowid + 6_000_000_000_000 AS rowid,
    id AS entity_id,
    'journal_entry_type' AS entity,
    'Journal entry type' AS category,
    CASE
    active
     	WHEN '1' THEN 'Active'
    ELSE 'Inactive'
    END
    AS status,
    NULL AS owner_id,
    NULL AS group_id,
    name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    description AS text,
    inserted_at,
    updated_at
    FROM
    journal_entry_types jet
    UNION ALL
    -- Knowledge management notes
    SELECT
    kmn.rowid + 7_000_000_000_000 AS rowid,
    kmn.id AS entity_id,
    'knowledge_management_note' AS entity,
    'Knowledge management note' AS category,
    kmn.status AS status,
    NULL AS owner_id,
    NULL AS group_id,
    kmn.title AS title,
    kmn.summary AS subtitle,
    NULL AS author,
    GROUP_CONCAT(t.name, ' · ') AS tags,
    NULL AS location,
    kmn.content AS text,
    kmn.inserted_at,
    kmn.updated_at
    FROM
    knowledge_management_notes kmn
    LEFT JOIN knowledge_management_note_tags kmnt
    ON
    kmn.id = kmnt.note_id
    LEFT JOIN tags t
    ON
    kmnt.tag_id = t.id
    GROUP BY
    entity_id
    UNION ALL
    -- Knowledge management relationship types
    SELECT
    rowid + 8_000_000_000_000 AS rowid,
    id AS entity_id,
    'knowledge_management_relationship_tpye' AS entity,
    'Relationship type' AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    name AS title,
    reverse_name AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    description AS text,
    inserted_at,
    updated_at
    FROM
    knowledge_management_relationship_types kmrt
    UNION ALL
    -- Project notes
    SELECT
    pn.rowid + 9_000_000_000_000 AS rowid,
    pn.id AS entity_id,
    'project_note' AS entity,
    'Project note' AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    p.name AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    pn.note AS text,
    pn.inserted_at,
    pn.updated_at
    FROM
    project_notes pn
    LEFT JOIN projects p
    ON
    pn.project_id = p.id
    UNION ALL
    -- Projects
    SELECT
    p.rowid + 10_000_000_000_000 AS rowid,
    p.id AS entity_id,
    'project' AS entity,
    'Project' AS category,
    CASE
    WHEN p.active THEN 'Active'
    ELSE 'Inactive'
    END
    AS status,
    NULL AS owner_id,
    NULL AS group_id,
    p.name AS title,
    NULL AS subtitle,
    NULL AS author,
    GROUP_CONCAT(t.name, ' · ') AS tags,
    NULL AS location,
    concat(p.description, ' · ', bp.name, ' · ', p.project_type, ' · ', p.status, ' · ', p.priority) AS text,
    p.inserted_at,
    p.updated_at
    FROM
    projects p
    LEFT JOIN project_tags pt
    ON
    p.id = pt.project_id
    LEFT JOIN tags t
    ON
    pt.tag_id = t.id
    LEFT JOIN business_partners bp
    ON
    p.business_partner_id = bp.id
    GROUP BY entity_id
    UNION ALL
    -- Timer notes
    SELECT
    tn.rowid + 11_000_000_000_000 AS rowid,
    tn.id AS entity_id,
    'timer_note' AS entity,
    'Timer note' AS category,
    NULL AS status,
    NULL AS owner_id,
    NULL AS group_id,
    NULL AS title,
    NULL AS subtitle,
    NULL AS author,
    NULL AS tags,
    NULL AS location,
    tn.note AS text,
    tn.inserted_at,
    tn.updated_at
    FROM
    timer_notes tn
    LEFT JOIN timers t
    ON
    tn.timer_id = t.id
    UNION ALL
    -- Timers
    SELECT
    t.rowid + 12_000_000_000_000 AS rowid,
    t.id AS entity_id,
    'timer' AS entity,
    'Timer' AS category,
    CASE
    WHEN t.end_stamp IS NULL THEN 'Open'
    ELSE 'Closed'
    END
    AS status,
    NULL AS owner_id,
    NULL AS group_id,
    concat(t.start_stamp, '–', t.end_stamp) AS title,
    NULL AS subtitle,
    NULL AS author,
    GROUP_CONCAT(ta.name, ' · ') AS tags,
    NULL AS location,
    concat(t.description, ' · ', bp.name, ' · ', p.name, ' · ', GROUP_CONCAT(tn.note, ' · ')) AS text,
    t.inserted_at,
    t.updated_at
    FROM
    timers t
    LEFT JOIN timer_tags tt
    ON
    t.id = tt.timer_id
    LEFT JOIN tags ta
    ON
    tt.tag_id = ta.id
    LEFT JOIN business_partners bp
    ON
    T.business_partner_id = bp.id
    LEFT JOIN projects p
    ON
    t.project_id = p.id
    LEFT JOIN timer_notes tn
    ON
    t.id = tn.timer_id
    GROUP BY entity_id
    UNION ALL
    -- Trips
    SELECT
    tt.rowid + 13_000_000_000_000 AS rowid,
    tt.id AS entity_id,
    'travel_trip' AS entity,
    'Trip' AS category,
    CASE
    WHEN tt.exit_date IS NULL THEN 'Ongoing'
    ELSE 'Complete'
    END
    AS status,
    tt.user_id AS owner_id,
    NULL AS group_id,
    u.user_name AS title,
    lc.country_name AS subtitle,
    u.user_name AS author,
    NULL AS tags,
    NULL AS location,
    concat(tt.description, ' · ', tt.entry_date, ' · ', tt.entry_point, ' · ', tt.exit_date, ' · ', tt.exit_point) AS text,
    tt.inserted_at,
    tt.updated_at
    FROM
    travel_trips tt
    LEFT JOIN users u
    ON
    tt.user_id = u.id
    LEFT JOIN locations_countries lc
    ON
    tt.country_id = lc.iso_3_country_code
    UNION ALL
    -- User documents
    SELECT
    ud.rowid + 14_000_000_000_000 AS rowid,
    ud.id AS entity_id,
    'user_document' AS entity,
    'User document' AS category,
    CASE
    WHEN ud.is_active = 0 THEN 'Invalidated'
    WHEN current_date > ud.expires_at THEN 'Expired'
    ELSE 'Valid'
    END
    AS status,
    ud.user_id AS owner_id,
    NULL AS group_id,
    ud.name AS title,
    u.user_name AS subtitle,
    u.user_name AS author,
    NULL AS tags,
    lc.country_name AS location,
    concat(ud.description, ' · ', u.user_name, ' · ', di.name, ' · ', ud.unique_reference_number, ' · ', ud.issued_at, ' · ', ud.expires_at, ' · ', ud.invalidation_reason) AS text,
    ud.inserted_at,
    ud.updated_at
    FROM
    user_documents ud
    LEFT JOIN document_issuers di
    ON
    ud.document_issuer_id = di.id
    LEFT JOIN users u
    ON
    ud.user_id = u.id
    LEFT JOIN locations_countries lc
    ON
    ud.country_id = lc.iso_3_country_code
    );
    """)
  end

  def down do
    execute("DROP VIEW IF EXISTS unified_search_view")
  end
end
