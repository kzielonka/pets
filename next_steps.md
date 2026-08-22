# Handoff: Next Steps for Map Pin Module Integration

Map pin clustering in `announcements_map` is fully implemented and tested (all 42 tests passing).

---

## 1. Current State
- **Clustering Algorithm**: Implemented in [`ClusteringGrid`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/clustering_grid.rb) as an Enumerable greedy clustering structure with memoized results and distance-based centroid merging.
- **Facade Integration**: [`AnnouncementsMap#search`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map.rb) returns clustered results (`SinglePin` / `GroupPin`).
- **Tests**: Full suite in `modules/announcements_map/test/` is completely green.

---

## 2. Action Items for the Next Session

### Step 1: Event Bus Integration for Announcements Map
- Subscribe `AnnouncementsMap` to `EventsBus` so it listens to `AnnouncementPublished` events and automatically records pins.
- Add event-driven tests verifying that publishing an announcement adds a pin into the map repository.

### Step 2: Integrate Module into Rails App
- Add `gem 'announcements_map', path: '../modules/announcements_map'` to [`rails/Gemfile`](file:///Users/krzysztofzielonka/Projects/pets/rails/Gemfile).
- Initialize and configure the facade in [`rails/config/initializers/dependencies.rb`](file:///Users/krzysztofzielonka/Projects/pets/rails/config/initializers/dependencies.rb).
- Subscribe `AnnouncementsMap` to the shared `EventsBus` instance in `dependencies.rb`.

### Step 3: Expose Map Search Endpoint
- Create a Rails controller endpoint `GET /api/announcements/map` that accepts bounding box query params (`top`, `right`, `bottom`, `left`) and calls `Rails.application.config.announcements_map.search(...)`.
- Return serialized JSON array with pin type (`single_pin` / `group_pin`), coordinates, IDs, and pin counts.
- Add Rails request/controller tests.

### Step 4: Frontend Map Integration
- Connect Vue 3 Leaflet/Map component in `frontend/` to the new map search endpoint.
- Support reactive re-fetching and cluster rendering when zooming/panning.
