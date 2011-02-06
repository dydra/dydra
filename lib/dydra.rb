require 'open-uri'
require 'rdf'      # @see http://rubygems.org/gems/rdf

module Dydra
  URI = RDF::URI('http://api.dydra.com/')
  URL = RDF::URI(ENV['DYDRA_URL'] || URI)

  autoload :Account,    'dydra/account'
  autoload :Client,     'dydra/client'
  autoload :Command,    'dydra/command'
  autoload :Job,        'dydra/job'
  autoload :Query,      'dydra/query'
  autoload :Repository, 'dydra/repository'
  autoload :Resource,   'dydra/resource'
  autoload :VERSION,    'dydra/version'

  class AuthenticationError < StandardError ; end
end
