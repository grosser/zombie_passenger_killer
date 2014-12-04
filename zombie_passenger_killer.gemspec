require './lib/zombie_passenger_killer/version'

Gem::Specification.new "zombie_passenger_killer", ZombiePassengerKiller::VERSION do |s|
  s.summary = "Guaranteed zombie passengers death"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/zombie_passenger_killer"
  s.files = `git ls-files lib Readme.md`.split("\n")
  s.executables = ["zombie_passenger_killer"]
  s.license = "MIT"
end
