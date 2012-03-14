$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'zombie_passenger_killer/version'

Gem::Specification.new "balepc-zombie_passenger_killer", ZombiePassengerKiller::VERSION do |s|
  s.summary = "Guaranteed zombie passengers death"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/zombie_passenger_killer"
  s.files = `git ls-files`.split("\n")
  s.executables = ["zombie_passenger_killer"]
  s.license = "MIT"
end
