#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'dydra'
  gem.homepage           = 'http://dydra.com/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Dydra.com SDK and command-line client.'
  gem.description        = gem.summary
  gem.rubyforge_project  = 'dydra'

  gem.author             = 'Datagraph'
  gem.email              = 'datagraph@googlegroups.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION bin/dydra) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w(dydra)
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = []
  gem.add_runtime_dependency     'rest-client',   '>= 1.6.1'
  gem.add_runtime_dependency     'sparql-client', '>= 0.0.9'
  gem.add_runtime_dependency     'rdf',           '~> 0.3.0'
  gem.add_development_dependency 'yard' ,         '>= 0.6.0'
  gem.add_development_dependency 'rspec',         '>= 2.4.0'
  gem.add_development_dependency 'rdf-spec',      '~> 0.3.0'
  gem.post_install_message       = nil
end
