require "json"

class EventsBus
  def initialize
    @subscribers = []
  end

  def publish(event)
    # TODO: later events will be handle by RabitMQ or other queue
    event = SerializableEvent.new(event)
    serialized_event = event.serialize
    deserialized_event = serialized_event.raw_deserialized_event
    @subscribers.each { |s| s.handle(deserialized_event) }
  end

  def register_subscriber(subscriber)
    @subscribers << subscriber
  end

  class SerializableEvent
    def initialize(event)
      @event = event
    end

    def serialize
      return @event.serialize if @event.respond_to?(:serialize)
      return serialize_from_type_and_payload if event_has_type_and_payload_methods
      return SerializedEvent.new(@event[:type], JSON.dump(@event[:payload])) if @event.is_a?(Hash)
      raise RuntimeError.new("can not serialize event #{event.inspect}")
    end

    def serialize_from_type_and_payload
      SerializedEvent.new(@event.type, JSON.dump(@event.payload))
    end
    
    def event_has_type_and_payload_methods
      @event.respond_to?(:type) && @event.respond_to?(:payload)
    end
  end
  private_constant :SerializableEvent

  class SerializedEvent
    def initialize(type, payload_json)
      @type = String(type).dup.freeze
      @payload_json = String(payload_json).dup.freeze
    end

    attr_reader :type

    def serialize
      self
    end

    def raw_deserialized_event
      DeserializedEvent.new(type, JSON.parse(@payload_json))
    end
  end

  class DeserializedEvent
    def initialize(type, payload)
      @type = String(type).dup.freeze
      @payload = Hash(payload)
    end

    attr_reader :type, :payload
  end
  private_constant :DeserializedEvent
end
