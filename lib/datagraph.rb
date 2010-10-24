require 'open-uri'
require 'rdf'      # @see http://rubygems.org/gems/rdf

module Datagraph
  URI = RDF::URI('http://api.datagraph.org/')
  URL = RDF::URI(ENV['DATAGRAPH_URL'] || URI)

  autoload :Account,    'datagraph/account'
  autoload :Client,     'datagraph/client'
  autoload :Command,    'datagraph/command'
  autoload :Process,    'datagraph/process'
  autoload :Query,      'datagraph/query'
  autoload :Repository, 'datagraph/repository'
  autoload :Resource,   'datagraph/resource'
  autoload :VERSION,    'datagraph/version'
end
