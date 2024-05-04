Gem::Specification.new do |s|
  s.name        = "events_bus"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Events bus"
  s.description = "Manages system events"
  s.authors     = ["Krzysztof Zielonka"]
  s.email       = "aknolezik@gmail.com"
  s.files       = ["lib/events_bus"]

  s.add_dependency "announcements", ">= 0"
  s.add_development_dependency "minitest", ">= 5"
  s.add_development_dependency "rake", ">= 13"
end
