# Events Bus Module

This module acts as an in-memory publish-subscribe broker used to asynchronously decouple the modular monolith submodules.

To simulate clean microservice/network boundaries, the event bus **serializes all events to JSON** and **deserializes them** before handing them to subscribers. This ensures that modules cannot share in-memory references or mutable states, allowing seamless extraction to a real message broker (e.g., RabbitMQ, Kafka) if necessary.

---

## public API

The public interface for this module is documented directly in the code of the [EventsBus Facade](file:///Users/krzysztofzielonka/Projects/pets/modules/events_bus/lib/events_bus.rb) using YARD/Ruby documentation comments.

---

## Directory Structure

```directory
├── lib/
│   ├── events_bus.rb            # Event bus facade, serializer, and deserializer
│   └── events_bus/
│       └── version.rb            # Gem version identifier
└── test/                         # Unit tests
```

---

## Usage Example

To publish an event, the event object must implement `.type` (returning a String type name) and `.payload` (returning a Hash containing JSON-serializable keys/values):

```ruby
events_bus = EventsBus.new

# Register subscriber
class AnnouncementSubscriber
  def handle(event)
    if event.type == "AnnouncementPublished"
      puts "Received ID: #{event.payload['id']}"
    end
  end
end

events_bus.register_subscriber(AnnouncementSubscriber.new)

# Publish event
class MyEvent
  def type; "AnnouncementPublished"; end
  def payload; { "id" => "123-abc" }; end
end

events_bus.publish(MyEvent.new)
```

---

## Running Tests

Run tests in isolation:
```bash
# Locally
bundle exec rake test

# Via Docker
docker compose exec web /bin/bash -c "cd events_bus; rake test"
```
