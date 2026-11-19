Library sample database — MongoDB, embedded (2,024 rows)

Tables that belong to another are folded into it as arrays, so the documents read the way the application uses them. The rest are collections of their own, joined by key as in the flat version.

Load it:
  sh import.sh                    (into mongodb://localhost:27017)
  sh import.sh "<connection string>"

Or one collection at a time: mongoimport --db library --collection <name> --file <name>.ndjson

Collections:
  addresses — 31 documents
  audit_logs — 20 documents
  authors — 10 documents
  book_tag_mappings — 30 documents
  book_tags — 40 documents
  books — 12 documents, each with its book_authors
  categories — 20 documents
  copies — 40 documents
  events — 10 documents, each with its event_registrations
  fine_policies — 4 documents
  fines — 60 documents
  languages — 10 documents
  libraries — 8 documents, each with its library_hours
  loans — 1,000 documents
  memberships — 35 documents
  notification_templates — 8 documents
  notifications — 250 documents
  order_items — 10 documents
  payments — 50 documents
  publishers — 60 documents
  purchase_orders — 10 documents
  reservations — 80 documents
  reviews — 50 documents
  roles — 4 documents
  staff_profiles — 10 documents
  suppliers — 20 documents
  users — 30 documents

Folded in (no collection of their own):
  book_authors — 16 rows, as the "book_authors" array on books (its book_id is the parent's _id)
  event_registrations — 40 rows, as the "event_registrations" array on events (its event_id is the parent's _id)
  library_hours — 56 rows, as the "library_hours" array on libraries (its library_id is the parent's _id)

Types: numeric columns are Decimal128, so totals stay exact; dates and timestamps are
Date values read as UTC (the data has no time zone); times and UUIDs are strings;
JSON columns are embedded objects.

Synthetic data, CC0-1.0, from databasesample.com. The same rows as the SQL and CSV files.
