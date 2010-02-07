require 'rdf'
require 'datagraph/version'

##
module Datagraph
  URL = RDF::URI.new('http://datagraph.org/')

  autoload :Client, 'datagraph/client'
end
