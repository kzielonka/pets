require "minitest/autorun"
require "events_bus"

class TestEventsBus < Minitest::Test

  class SimpleSubscriber
    def initialize
      @events = []
    end

    def handle(event)
      @events << event
    end

    def last_event
      @events.last
    end

    def number_of_received_events
      @events.size
    end
  end

  class SampleEvent1
    def serialize
      EventsBus::SerializedEvent.new("type1", "{ \"a\": \"b\" }")
    end
  end

  class SampleEvent2
    def type
      "type2"
    end

    def payload
      { "c" => "d" }
    end
  end

  def setup
    @events_bus = EventsBus.new
    @simple_subscriber = SimpleSubscriber.new
    @events_bus.register_subscriber(@simple_subscriber)
  end

  def test_publishes_event_with_serialize_method
    event = SampleEvent1.new
    @events_bus.publish(event)
    assert_equal 1, @simple_subscriber.number_of_received_events
    assert_equal "type1", @simple_subscriber.last_event.type
    assert_equal({ "a" => "b" }, @simple_subscriber.last_event.payload)
  end

  def test_publishes_event_with_type_and_payload_methods
    simple_subscriber = SimpleSubscriber.new
    @events_bus.register_subscriber(simple_subscriber)
    event = SampleEvent2.new
    @events_bus.publish(event)
    assert_equal 1, @simple_subscriber.number_of_received_events
    assert_equal "type2", @simple_subscriber.last_event.type
    assert_equal({ "c" => "d" }, @simple_subscriber.last_event.payload)
  end
end
