# Announcements Map Module

This module tracks announcement coordinates and provides spatial bounding box filtering, rendering map pins and performing greedy dynamic radius clustering.

---

## Public API

The public interface for this module is documented directly in the code of the [AnnouncementsMap Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map.rb) using YARD/Ruby documentation comments.

### Key Operations:
- `add_pin(announcement_id, latitude, longitude)`: Stores geographic coordinates for an announcement pin.
- `remove_pin(announcement_id)`: Removes coordinates for an announcement pin.
- `search(top, right, bottom, left)`: Returns an array of `SearchResults::SinglePin` and `SearchResults::GroupPin` within the bounding box, clustering nearby pins together.
- `subscribe(events_bus)`: Registers handlers for `AnnouncementPublished` and `AnnouncementUnpublished` events.
- `reset!`: Wipes the pin repository (used in tests).

---

## Directory Structure

```directory
├── lib/
│   ├── announcements_map.rb          # Public facade
│   └── announcements_map/
│       ├── bounding_box.rb           # Bounding box value object & builder
│       ├── clustering_grid.rb        # Enumerable greedy clustering algorithm
│       ├── grid.rb                   # Spatial 2D cell binning data structure
│       ├── haversine_distance.rb     # Geographic distance calculator (km)
│       ├── latitude.rb               # Latitude validator (-90 to 90)
│       ├── longitude.rb              # Longitude validator (-180 to 180)
│       ├── pin.rb                    # Map pin model
│       ├── repos.rb                  # Repository adapter (InMemoryRepo & ActiveRecordRepo)
│       ├── search_results.rb         # Search results structures (SinglePin, GroupPin)
│       └── types.rb                  # Type builder wrappers
└── test/                             # Map module unit tests
```

---

## Current Clustering Architecture

Clustering currently uses a 2-phase approach at request time:
1. **Grid Binning ([`Grid`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/grid.rb))**:
   Partitions the viewport bounding box into a 2D array of cells ($10 \times 20$), mapping raw coordinates to their respective cell in $O(1)$ time.
2. **Greedy Radius Clustering ([`ClusteringGrid`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/clustering_grid.rb))**:
   An `Enumerable` that processes non-empty cells in descending order of density (pin count). For each seed cell, it greedily absorbs neighboring unassigned cells within dynamic merge radius $D = \text{height}_{\text{km}} \times 0.08$ (calculated via Haversine distance), producing either a `SinglePin` (1 pin) or a `GroupPin` (weighted centroid of merged pins).

---

## Future Roadmap: Hierarchical Multi-Zoom Precalculated Grid

For scaling to large datasets (hundreds of thousands to millions of pins worldwide), the runtime binning approach will be evolved into a **Hierarchical Precalculated Spatial Tile Pyramid** (similar to Mapbox Supercluster / Slippy Map Tiles):

### Key Concepts:
1. **Fixed Discrete Zoom Levels ($Z \in [0..16]$)**:
   The world is partitioned into $2^Z \times 2^Z$ fixed spatial tile cells per zoom level. Translating any `(lat, lon)` into `(cell_x, cell_y)` at zoom $Z$ is a fast, constant-time calculation.
2. **Asynchronous Precalculation on Event Publish**:
   When an `AnnouncementPublished` event arrives:
   - For each zoom level $Z$, the target tile cell is identified.
   - The cell's count is incremented and its running weighted centroid is updated incrementally in $O(1)$ arithmetic:
     $$\text{Centroid}_{\text{new}} = \frac{(\text{Centroid}_{\text{old}} \times N) + \text{Pin}_{\text{new}}}{N + 1}$$
   - Pre-aggregated records `(zoom, cell_x, cell_y, pin_count, centroid_lat, centroid_lon, single_pin_id)` are persisted in a dedicated read-model table `map_grid_cells`.
3. **Instantaneous Read Queries ($O(1)$ Index Lookups)**:
   - When the frontend requests pins for a viewport at zoom level $Z$, the backend performs a direct indexed range scan over precalculated tiles:
     ```sql
     SELECT * FROM map_grid_cells 
     WHERE zoom = :zoom AND cell_x BETWEEN :min_x AND :max_x AND cell_y BETWEEN :min_y AND :max_y;
     ```
   - Query response time becomes constant (< 2ms) and completely independent of the total number of pins stored in the database.

---

## Infrastructure & Database Schema

- `:in_memory` repository strategy for unit tests and local isolation.
- `:active_record` repository strategy backed by the `public_announcements` PostgreSQL table.

---

## Events

This module subscribes to:
- `AnnouncementPublished` ➔ Adds announcement pin coordinates to the map read model.
- `AnnouncementUnpublished` ➔ Removes announcement pin coordinates from the map read model.

---

## Running Tests

Run tests in isolation:
```bash
# Locally
bundle exec rake test

# Via Docker
docker compose exec web /bin/bash -c "cd ../modules/announcements_map; rake test"

# Run a specific test by name
docker compose exec web /bin/bash -c "cd ../modules/announcements_map; rake test N=test_returns_single_pin"
```
