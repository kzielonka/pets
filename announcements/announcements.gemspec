Gem::Specification.new do |s|
  s.name        = "announcements"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Announcements"
  s.description = "Encapsulates announcements management logic"
  s.authors     = ["Krzysztof Zielonka"]
  s.email       = "aknolezik@gmail.com"
  s.files       = ["lib/announcements"]

  s.add_dependency "activerecord", ">= 7"
  s.add_development_dependency "minitest", ">= 5"
  s.add_development_dependency "rake", ">= 13"
end
