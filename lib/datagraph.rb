require 'rdf'
require 'datagraph/version'

##
module Datagraph
  URL = RDF::URI.new(ENV['DATAGRAPH_URL'] || 'http://datagraph.org/')

  autoload :Client, 'datagraph/client'
end
