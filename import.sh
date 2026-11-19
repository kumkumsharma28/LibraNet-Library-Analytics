#!/bin/sh
# Loads the library sample database into MongoDB.
#   sh import.sh                       # mongodb://localhost:27017
#   sh import.sh "mongodb+srv://…"     # any connection string
# Needs mongoimport and mongosh (MongoDB Database Tools and Shell).
set -e
URI="${1:-mongodb://localhost:27017}"
DB="library"
cd "$(dirname "$0")"
mongoimport --uri "$URI" --db "$DB" --collection addresses --drop --file addresses.ndjson
mongoimport --uri "$URI" --db "$DB" --collection audit_logs --drop --file audit_logs.ndjson
mongoimport --uri "$URI" --db "$DB" --collection authors --drop --file authors.ndjson
mongoimport --uri "$URI" --db "$DB" --collection book_tag_mappings --drop --file book_tag_mappings.ndjson
mongoimport --uri "$URI" --db "$DB" --collection book_tags --drop --file book_tags.ndjson
mongoimport --uri "$URI" --db "$DB" --collection books --drop --file books.ndjson
mongoimport --uri "$URI" --db "$DB" --collection categories --drop --file categories.ndjson
mongoimport --uri "$URI" --db "$DB" --collection copies --drop --file copies.ndjson
mongoimport --uri "$URI" --db "$DB" --collection events --drop --file events.ndjson
mongoimport --uri "$URI" --db "$DB" --collection fine_policies --drop --file fine_policies.ndjson
mongoimport --uri "$URI" --db "$DB" --collection fines --drop --file fines.ndjson
mongoimport --uri "$URI" --db "$DB" --collection languages --drop --file languages.ndjson
mongoimport --uri "$URI" --db "$DB" --collection libraries --drop --file libraries.ndjson
mongoimport --uri "$URI" --db "$DB" --collection loans --drop --file loans.ndjson
mongoimport --uri "$URI" --db "$DB" --collection memberships --drop --file memberships.ndjson
mongoimport --uri "$URI" --db "$DB" --collection notification_templates --drop --file notification_templates.ndjson
mongoimport --uri "$URI" --db "$DB" --collection notifications --drop --file notifications.ndjson
mongoimport --uri "$URI" --db "$DB" --collection order_items --drop --file order_items.ndjson
mongoimport --uri "$URI" --db "$DB" --collection payments --drop --file payments.ndjson
mongoimport --uri "$URI" --db "$DB" --collection publishers --drop --file publishers.ndjson
mongoimport --uri "$URI" --db "$DB" --collection purchase_orders --drop --file purchase_orders.ndjson
mongoimport --uri "$URI" --db "$DB" --collection reservations --drop --file reservations.ndjson
mongoimport --uri "$URI" --db "$DB" --collection reviews --drop --file reviews.ndjson
mongoimport --uri "$URI" --db "$DB" --collection roles --drop --file roles.ndjson
mongoimport --uri "$URI" --db "$DB" --collection staff_profiles --drop --file staff_profiles.ndjson
mongoimport --uri "$URI" --db "$DB" --collection suppliers --drop --file suppliers.ndjson
mongoimport --uri "$URI" --db "$DB" --collection users --drop --file users.ndjson
mongosh "$URI" --quiet --eval 'db = db.getSiblingDB("library");
  db.audit_logs.createIndex({ user_id: 1 });
  db.books.createIndex({ "book_authors.author_id": 1 });
  db.book_tag_mappings.createIndex({ book_id: 1 });
  db.book_tag_mappings.createIndex({ tag_id: 1 });
  db.books.createIndex({ category_id: 1 });
  db.books.createIndex({ language_id: 1 });
  db.books.createIndex({ publisher_id: 1 });
  db.copies.createIndex({ book_id: 1 });
  db.copies.createIndex({ library_id: 1 });
  db.events.createIndex({ "event_registrations.user_id": 1 });
  db.events.createIndex({ library_id: 1 });
  db.fines.createIndex({ fine_policy_id: 1 });
  db.fines.createIndex({ loan_id: 1 });
  db.libraries.createIndex({ address_id: 1 });
  db.loans.createIndex({ copy_id: 1 });
  db.loans.createIndex({ membership_id: 1 });
  db.loans.createIndex({ staff_id: 1 });
  db.memberships.createIndex({ library_id: 1 });
  db.memberships.createIndex({ user_id: 1 });
  db.notifications.createIndex({ template_id: 1 });
  db.notifications.createIndex({ user_id: 1 });
  db.order_items.createIndex({ book_id: 1 });
  db.order_items.createIndex({ purchase_order_id: 1 });
  db.payments.createIndex({ fine_id: 1 });
  db.payments.createIndex({ staff_id: 1 });
  db.publishers.createIndex({ address_id: 1 });
  db.purchase_orders.createIndex({ staff_id: 1 });
  db.purchase_orders.createIndex({ supplier_id: 1 });
  db.reservations.createIndex({ book_id: 1 });
  db.reservations.createIndex({ membership_id: 1 });
  db.reviews.createIndex({ book_id: 1 });
  db.reviews.createIndex({ user_id: 1 });
  db.staff_profiles.createIndex({ library_id: 1 });
  db.staff_profiles.createIndex({ user_id: 1 });
  db.suppliers.createIndex({ address_id: 1 });
  db.users.createIndex({ address_id: 1 });
  db.users.createIndex({ role_id: 1 });
'
