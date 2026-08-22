# Announcements Map Module

This module tracks announcement coordinates and provides spatial bounding box filtering, rendering map pins and performing greedy dynamic radius clustering.

---

## Public API

The public interface for this module is documented directly in the code of the [AnnouncementsMap Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map.rb) using YARD/Ruby documentation comments.

### Key Operations:
- `add_pin(announcement_id, latitude, longitude)`: Stores geographic coordinates for an announcement pin.
- `search(top, right, bottom, left)`: Returns an array of `SearchResults::SinglePin` and `SearchResults::GroupPin` within the bounding box, clustering nearby pins together.

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
│       ├── repos.rb                  # Repository adapter (InMemoryRepo)
│       ├── search_results.rb         # Search results structures (SinglePin, GroupPin)
│       └── types.rb                  # Type builder wrappers
└── test/                             # Map module unit tests
```

---

## Clustering Architecture

Clustering uses a 2-phase approach:
1. **Grid Binning ([`Grid`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/grid.rb))**:
   Partitions the viewport bounding box into a 2D array of cells ($10 \times 20$), mapping raw coordinates to their respective cell in $O(1)$ time.
2. **Greedy Radius Clustering ([`ClusteringGrid`](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/clustering_grid.rb))**:
   An `Enumerable` that processes non-empty cells in descending order of density (pin count). For each seed cell, it greedily absorbs neighboring unassigned cells within dynamic merge radius $D = \text{height}_{\text{km}} \times 0.08$ (calculated via Haversine distance), producing either a `SinglePin` (1 pin) or a `GroupPin` (weighted centroid of merged pins).

---

## Infrastructure & Database Schema

Currently, this module relies on the `:in_memory` repository strategy for holding pin coordinates.

---

## Events

This module does not publish or subscribe to any system events yet.

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
