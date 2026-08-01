# Announcements Search Module

This module manages a read model database table optimized for geospatial queries, allowing public spatial/location searches on published announcements.

---

## public API

The public interface for this module is documented directly in the code of the [AnnouncementsSearch Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_search/lib/announcements_search.rb) using YARD/Ruby documentation comments.

---

## Directory Structure

```directory
├── lib/
│   ├── announcements_search.rb   # Public facade
│   └── announcements_search/
│       ├── announcement.rb       # Search read-model data structure
│       └── repos.rb              # Repository adapter (InMemoryRepo / ActiveRecordRepo)
└── test/                         # Module unit tests
```

---

## Infrastructure & Database Schema

This module owns and writes to the `public_announcements` table, which features a PostgreSQL GIST index on geographic points for high-performance spatial querying.

### Database Table: `public_announcements`
- `id` (uuid, primary key): Matches the primary announcement ID.
- `title` (string): Title of the announcement.
- `content` (string): Description of the announcement.
- `location` (point, index): PostgreSQL point type `(longitude, latitude)` with GIST index.
- `created_at` / `updated_at` (timestamps)

---

## Event Subscriptions

This module listens to the following events from the `EventsBus` to keep its read model synchronized:
- **`AnnouncementPublished`**: Triggers insertion/update of the announcement into the `public_announcements` search table.
- **`AnnouncementUnpublished`**: Triggers deletion of the announcement from the `public_announcements` search table.

---

## Running Tests

Run tests in isolation:
```bash
# Locally
bundle exec rake test

# Via Docker
docker compose exec web /bin/bash -c "cd announcements_search; rake test"
```
