Gem::Specification.new do |s|
  s.name        = "announcements_map"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Announcements Map"
  s.description = "Encapsulates announcements map logic"
  s.authors     = ["Krzysztof Zielonka"]
  s.email       = "aknolezik@gmail.com"
  s.files       = ["lib/announcements"]

  s.add_dependency "activerecord", ">= 7"
  s.add_development_dependency "minitest", ">= 5"
  s.add_development_dependency "rake", ">= 13"
end
