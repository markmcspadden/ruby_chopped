# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_chopped/version"

Gem::Specification.new do |s|
  s.name        = "ruby_chopped"
  s.version     = RubyChopped::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mark McSpadden"]
  s.email       = ["markmcspadden@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Creates a ruby project with two random gems}
  s.description = %q{Creates a ruby project with two random gems from rubygems.org top downloads of the day}

  s.rubyforge_project = "ruby_chopped"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'rest-client', '1.6.3'
end
