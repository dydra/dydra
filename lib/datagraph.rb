require 'rdf'
require 'datagraph/version'

##
module Datagraph
  URI = RDF::URI.new('http://datagraph.org/')
  URL = RDF::URI.new(ENV['DATAGRAPH_URL'] || URI)

  autoload :Client, 'datagraph/client'
end
