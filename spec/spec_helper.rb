# This is free and unencumbered software released into the public domain.

require 'dydra'
require 'rdf/spec'

RSpec.configure do |config|
  config.include RDF::Spec::Matchers
  config.exclusion_filter = {:ruby => lambda { |version|
    RUBY_VERSION.to_s !~ /^#{version}/
  }}
end

Dydra.setup!
