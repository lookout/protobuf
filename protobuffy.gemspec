# encoding: UTF-8
$:.push ::File.expand_path("../lib", __FILE__)
require "protobuf/version"

::Gem::Specification.new do |s|
  s.name          = 'protobuffy'
  s.version       = ::Protobuf::VERSION
  s.date          = ::Time.now.strftime('%Y-%m-%d')
  s.license       = 'WTFPL'

  s.authors       = ['BJ Neilsen', 'Brandon Dewitt', 'Devin Christensen', 'Adam Hutchison', 'R. Tyler Croy',]
  s.email         = ['bj.neilsen+protobuf@gmail.com', 'brandonsdewitt+protobuf@gmail.com', 'quixoten@gmail.com', 'liveh2o@gmail.com', 'tyler@monkeypox.org']
  s.homepage      = 'https://github.com/lookout/protobuffy'
  s.summary       = "Google Protocol Buffers serialization and RPC implementation for Ruby."
  s.description   = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.2'
  s.add_dependency 'middleware'
  s.add_dependency 'multi_json'
  s.add_dependency 'thor'

  s.add_development_dependency 'rack'
  s.add_development_dependency 'faraday'
  s.add_development_dependency 'ffi-rzmq'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '2.99.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'perftools.rb', '~> 2.0.1'
end
