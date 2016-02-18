Gem::Specification.new do |s|
  s.name        = 'infor_client'
  s.version     = '0.0.1'
  s.date        = '2016-02-09'
  s.summary     = "Infor Retail API Client"
  s.description = "A Client for the Infor Retail API"
  s.authors     = ["Brian Roth"]
  s.email       = 'brianroth@gmail.com'
  s.files       = `git ls-files -z`.split("\x0")
  s.homepage    = 'https://github.com/brianroth/infor_client'
  s.license     = 'MIT'
  s.executables << 'list_hierarchies'
end