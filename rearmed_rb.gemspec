lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rearmed/version.rb'

Gem::Specification.new do |s|
  s.name        = 'rearmed_rb'
  s.version     =  Rearmed::VERSION
  s.author	= "Weston Ganger"
  s.email       = 'westonganger@gmail.com'
  s.homepage 	= 'https://github.com/westonganger/rearmed_rb'
  
  s.summary     = "Ruby method toolbox with new methods for both Ruby and Rails"
  s.description = "Ruby method toolbox with new methods for both Ruby and Rails"
  s.files = Dir.glob("{lib/**/*}") + %w{ LICENSE README.md Rakefile CHANGELOG.md }
  s.test_files  = Dir.glob("{test/**/*}")

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'bundler'

  s.required_ruby_version = '>= 1.9.3'
  s.require_path = 'lib'
end
