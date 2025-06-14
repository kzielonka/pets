class AnnouncementsMap
  class Longitude
    include Comparable
    InvalidError = Class.new(StandardError)

    def self.parse(value)
      new(Float(value))
    rescue ArgumentError
      raise InvalidError, "Invalid longitude value: #{value.inspect}"
    end

    def self.valid?(value)
      value = Float(value)
      value >= -180 && value <= 180
    rescue ArgumentError
      false
    end

    def to_f
      value
    end

    def <=>(other)
      return nil unless other.is_a?(self.class)
      value <=> other.value
    end

    protected

    attr_reader :value

    private

    def initialize(value)
      @value = value
      raise InvalidError, "Longitude must be between -180 and 180" unless self.class.valid?(@value)
    end
  end
  private_constant :Longitude
end 
