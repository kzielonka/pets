class AnnouncementsMap
  class Latitude
    include Comparable
    InvalidError = Class.new(StandardError)

    def self.parse(value)
      new(Float(value))
    rescue ArgumentError
      raise InvalidError, "Invalid latitude value: #{value.inspect}"
    end

    def self.valid?(value)
      value = Float(value)
      value >= -90 && value <= 90
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
      raise InvalidError, "Latitude must be between -90 and 90" unless self.class.valid?(@value)
    end
  end
  private_constant :Latitude
end 
