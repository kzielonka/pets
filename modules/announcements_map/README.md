# Announcements Map Module

This module tracks announcement coordinates and provides spatial bounding box filtering, laying the groundwork for rendering map pins and map pin clustering.

---

## public API

The public interface for this module is documented directly in the code of the [AnnouncementsMap Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map.rb) using YARD/Ruby documentation comments.

---

## Directory Structure

```directory
├── lib/
│   ├── announcements_map.rb      # Public facade
│   └── announcements_map/
│       ├── bounding_box.rb       # Bounding box value object
│       ├── haversine_distance.rb # Geographic distance calculator
│       ├── latitude.rb           # Latitude validator
│       ├── longitude.rb          # Longitude validator
│       ├── pin.rb                # Map pin model
│       ├── repos.rb              # Repository adapter (InMemoryRepo)
│       ├── search_results.rb     # Search results structures (SinglePin, GroupPin)
│       └── types.rb              # Type builder wrappers
└── test/                         # Map module unit tests
```

---

## Infrastructure & Database Schema

Currently, this module relies on the `:in_memory` repository strategy for holding pin coordinates.

---

## Events
This module does not publish or subscribe to any system events.

---

## Running Tests

Run tests in isolation:
```bash
# Locally
bundle exec rake test

# Via Docker
docker compose exec web /bin/bash -c "cd announcements_map; rake test"
```
