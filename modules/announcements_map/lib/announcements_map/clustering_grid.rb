# frozen_string_literal: true

class AnnouncementsMap
  # A stateful decorator over Grid that performs greedy radius-based clustering.
  # Implements Enumerable — iterating yields SinglePin / GroupPin results.
  #
  # Usage:
  #   cg = ClusteringGrid.new(bounding_box)
  #   cg.add_pin(pin)
  #   cg.each { |result| ... }   # or cg.to_a, cg.map, etc.
  class ClusteringGrid
    include Enumerable

    MERGE_RADIUS_FACTOR = 0.08

    def initialize(bb)
      @bb = Types.BoundingBox(bb)
      @grid = Grid.new(10, 20, @bb)
      @assigned = Set.new
    end

    def add_pin(pin)
      @results = nil
      pin = Types::Pin(pin)
      @grid.add_pin(pin)
    end

    def each(&block)
      results.each(&block)
    end

    private

    def results
      @results ||= compute_results
    end

    def compute_results
      @assigned = Set.new
      items = []
      until all_assigned?
        x, y = next_highest_weight_unassigned
        nearby = unassigned_cells_within(x, y, merge_radius_km)
        cluster = merge_and_assign([[x, y]] + nearby)
        items << build_result(cluster)
      end
      items
    end

    def merge_radius_km
      @bb.height_in_km * MERGE_RADIUS_FACTOR
    end

    Cluster = Struct.new(:count, :latitude, :longitude, :pins)
    private_constant :Cluster

    def all_assigned?
      non_empty_cells.all? { |x, y| @assigned.include?([x, y]) }
    end

    def next_highest_weight_unassigned
      non_empty_cells
        .reject { |x, y| @assigned.include?([x, y]) }
        .max_by { |x, y| @grid.number_of_pins(x, y) }
    end

    def unassigned_cells_within(x, y, distance_km)
      seed_lat, seed_lon = @grid.centroid_of(x, y)
      non_empty_cells
        .reject { |ox, oy| @assigned.include?([ox, oy]) || (ox == x && oy == y) }
        .select do |ox, oy|
          other_lat, other_lon = @grid.centroid_of(ox, oy)
          HaversineDistance.new(seed_lat, seed_lon, other_lat, other_lon).km <= distance_km
        end
    end

    def merge_and_assign(cells)
      cells.each { |x, y| @assigned.add([x, y]) }
      all_pins = cells.flat_map { |x, y| @grid.pins_in(x, y) }
      avg_lat = all_pins.sum { |p| p.latitude.to_f } / all_pins.size
      avg_lon = all_pins.sum { |p| p.longitude.to_f } / all_pins.size
      Cluster.new(all_pins.size, avg_lat, avg_lon, all_pins)
    end

    def build_result(cluster)
      if cluster.count == 1
        pin = cluster.pins.first
        SearchResults::SinglePin.new(pin.id, pin.latitude, pin.longitude)
      else
        SearchResults::GroupPin.new(cluster.count, cluster.latitude, cluster.longitude)
      end
    end

    def non_empty_cells
      cells = []
      1.upto(@grid.width) do |x|
        1.upto(@grid.height) do |y|
          cells << [x, y] if @grid.number_of_pins(x, y).positive?
        end
      end
      cells
    end
  end
end
