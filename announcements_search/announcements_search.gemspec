Gem::Specification.new do |s|
  s.name        = "announcements_search"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Announcements search"
  s.description = "Encapsulates announcements search logic"
  s.authors     = ["Krzysztof Zielonka"]
  s.email       = "aknolezik@gmail.com"
  s.files       = ["lib/announcements_search"]

  s.add_dependency "activerecord", ">= 7"
  s.add_dependency "announcements", ">= 0"
  s.add_development_dependency "minitest", ">= 5"
  s.add_development_dependency "rake", ">= 13"
end
