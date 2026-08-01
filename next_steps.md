# Handoff: Next Steps for Map Pin Clustering

We completed upgrading the backend stack to **Rails 8.1.3.1** and **Ruby 3.3.4**, updated the frontend to **Vue 3.5.40**, and documented the modular monolith. 

The next item on the roadmap is implementing the map pin clustering algorithm in the `announcements_map` module.

---

## 1. Context & Goal
The frontend displays announcements on a map. To avoid visual clutter and performance issues when there are many close pins, the map needs to cluster pins together. 
The test `test_search_for_pins_in_groups` in [announcements_map_test.rb](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/test/announcements_map_test.rb) is currently failing because this logic is not yet implemented.

---

## 2. Technical Design: Hybrid Grid + Greedy Radius Clustering
To balance zoom-dependent clustering and O(1) viewport performance, we designed a hybrid approach:

### Phase 1: Grid Binning (Viewport Capping)
1. Split the viewport bounding box `(top, right, bottom, left)` into an $M \times M$ grid (e.g. $20 \times 20 = 400$ cells).
2. Assign each raw pin to a grid cell.
3. For each active cell, compute:
   * **Weight**: Total count of pins inside that cell.
   * **Centroid**: The average latitude and longitude of the pins in the cell.
4. This reduces $N$ pins to a maximum of 400 cell-nodes, capping execution time.

### Phase 2: Greedy Radius Clustering on Grid Centroids
1. Calculate a dynamic search radius $D$ as a percentage of the map dimensions (e.g., $D = (\text{top} - \text{bottom}) \times 0.08$). This makes the clustering **zoom-dependent** without needing a zoom-level variable.
2. Run a greedy clustering pass on the cell-nodes:
   * Select the unassigned cell-node with the highest weight.
   * Find all other unassigned cell-nodes within distance $D$ (calculated using the [HaversineDistance](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/haversine_distance.rb) helper).
   * Merge them, sum their weights, and compute the combined centroid.
3. Output the results:
   * Clusters with weight = 1 ➔ Return `SearchResults::SinglePin`.
   * Clusters with weight > 1 ➔ Return `SearchResults::GroupPin`.

---

## 3. Action Items for the Next Session
1. **Fix Test Bugs**:
   * Open [announcements_map_test.rb](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/test/announcements_map_test.rb).
   * Fix the parameter typo `longutde` ➔ `longitude` in assertions.
   * Fix `assert_single_pin` to compare with the parameter variable `announcement_id` rather than the literal string `"announcement_id"`.
   * Adjust `assert_has_group_pin` parameters in `test_search_for_pins_in_groups` to verify `4` pins instead of the string `"announcement_id"`.
2. **Implement Algorithm**:
   * Implement the `SearchAlg` class in [search_alg.rb](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map/search_alg.rb).
3. **Hook up Facade**:
   * Update `AnnouncementsMap#search` in [announcements_map.rb](file:///Users/krzysztofzielonka/Projects/pets/modules/announcements_map/lib/announcements_map.rb) to use the new `SearchAlg` instead of returning raw pins.
4. **Verify**:
   * Run the test suite: `docker compose exec web /bin/bash -c "cd announcements_map; rake test"` (or locally: `bundle exec rake test` inside the module folder).
