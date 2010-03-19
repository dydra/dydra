#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

GEMSPEC = Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'datagraph'
  gem.homepage           = 'http://github.com/datagraph/datagraph'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Datagraph.org API client.'
  gem.description        = gem.summary
  gem.rubyforge_project  = 'datagraph'

  gem.authors            = ['Arto Bendiken', 'Ben Lavender', 'Josh Huckabee']
  gem.email              = 'arto.bendiken@gmail.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE VERSION bin/datagraph) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w(datagraph)
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.2'
  gem.requirements               = []
  gem.add_development_dependency 'rdf-spec',    '>= 0.1.0'
  gem.add_development_dependency 'rspec',       '>= 1.3.0'
  gem.add_development_dependency 'yard' ,       '>= 0.5.3'
  gem.add_runtime_dependency     'rdf',         '>= 0.1.1'
  gem.add_runtime_dependency     'rdfbus',      '>= 0.0.1'
  gem.post_install_message       = nil
end
