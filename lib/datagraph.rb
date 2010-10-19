require 'rdf' # @see http://rubygems.org/gems/rdf

module Datagraph
  URI = RDF::URI('http://api.datagraph.org/')
  URL = RDF::URI(ENV['DATAGRAPH_URL'] || URI)

  autoload :Client,  'datagraph/client'
  autoload :VERSION, 'datagraph/version'
end
