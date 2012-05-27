# This is free and unencumbered software released into the public domain.

if (!defined?(JSON))
  begin
    require 'json'
  rescue LoadError
    require 'json_pure'
  end
end

require 'open-uri'
require 'rdf'      # @see http://rubygems.org/gems/rdf

##
# Dydra.com software development kit (SDK) for Ruby.
#
# @see http://docs.dydra.com/sdk/ruby
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
  autoload :Revision,   'dydra/revision'
  autoload :VERSION,    'dydra/version'

  class AuthenticationError < StandardError; end

  # Used for specifying repositories without owner name, maybe one day
  # queries too.
  class RepositoryMisspecified < ::ArgumentError; end

  class MalformedQuery < ::StandardError; end

  # Used for query errors that come back over HTTP but that the client library
  # catches
  class QueryError < ::StandardError; end

  ##
  # @private
  # @see    Client.authenticate!
  # @return [void]
  def self.authenticate!(*args)
    Client.authenticate!(*args)
  end

  ##
  # @private
  # @see    Client.setup!
  # @return [void]
  def self.setup!(*args)
    Client.setup!(*args)
  end
end # Dydra
