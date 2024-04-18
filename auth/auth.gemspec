Gem::Specification.new do |s|
  s.name        = "auth"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Auth"
  s.description = "Encapsulates users management logic"
  s.authors     = ["Krzysztof Zielonka"]
  s.email       = "aknolezik@gmail.com"
  s.files       = ["lib/auth"]

  s.add_development_dependency "minitest", ">= 5"
  s.add_development_dependency "rake", ">= 13"
end
