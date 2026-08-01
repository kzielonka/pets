# Announcements Module

This module manages the lifecycle of missing/found pet announcements, including draft creation, updating titles/content/locations, publishing, and unpublishing.

---

## public API

The public interface for this module is documented directly in the code of the [Announcements Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements/lib/announcements.rb) using YARD/Ruby documentation comments.

---

## Directory Structure

```directory
├── lib/
│   ├── announcements.rb          # Public facade
│   └── announcements/
│       ├── announcement.rb       # Announcement domain model
│       ├── errors.rb             # Module-specific errors
│       ├── location.rb           # Location value object (latitude, longitude)
│       ├── repos.rb              # Repository adapter (InMemoryRepo / ActiveRecordRepo)
│       ├── serialized_announcement.rb # Read-model representation
│       └── users.rb              # User wrapper DTO
└── test/                         # Module unit tests
```

---

## Infrastructure & Database Schema

This module owns and writes to the `announcements` table when using the `:active_record` repository.

### Database Table: `announcements`
- `id` (uuid, primary key): Unique identifier.
- `draft` (boolean, null: false): True if this announcement is a draft.
- `owner_id` (string, index): Owner user ID.
- `title` (string): Title of the announcement.
- `content` (text): Detailed description of the missing/found pet.
- `latitude` (decimal) / `longitude` (decimal): Location coordinates.
- `created_at` / `updated_at` (timestamps)

---

## Events Published

- **`AnnouncementPublished`**: Emitted when a draft announcement is published.
  - Payload: `{ "id" => String, "title" => String, "content" => String, "location" => { "latitude" => Float, "longitude" => Float } }`
- **`AnnouncementUnpublished`**: Emitted when a published announcement is reverted back to a draft.
  - Payload: `{ "id" => String }`

---

## Running Tests

Run tests in isolation:
```bash
# Locally
ruby -Ilib:test test/announcements_test.rb

# Via Docker
docker compose exec web /bin/bash -c "cd announcements; rake test"
```
