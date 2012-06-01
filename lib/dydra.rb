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
  autoload :Operation,  'dydra/operation'
  autoload :Query,      'dydra/query'
  autoload :Repository, 'dydra/repository'
  autoload :Resource,   'dydra/resource'
  autoload :Revision,   'dydra/revision'
  autoload :RPC,        'dydra/rpc'
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
  # Authenticates with Dydra.com.
  #
  # @param  [Hash{Symbol => Object}] options
  # @option options [String] :token    (nil)
  # @option options [String] :account  (nil)
  # @option options [String] :password (nil)
  # @return [void]
  def self.authenticate!(options = {})
    self.setup!(options)
  end

  ##
  # @private
  # @param  [Hash{Symbol => Object}] options
  # @option options [String] :token    (nil)
  # @option options [String] :account  (nil)
  # @option options [String] :password (nil)
  # @return [void]
  def self.setup!(options = {})
    unless options.empty?
      case
        when options[:token]
          ENV['DYDRA_TOKEN'] = options[:token].to_s
        when options[:account]
          ENV['DYDRA_ACCOUNT'] = options[:account].to_s
          ENV['DYDRA_PASSWORD'] = options[:password].to_s
        when options[:user] # @deprecated
          ENV['DYDRA_ACCOUNT'] = options[:user].to_s
          ENV['DYDRA_PASSWORD'] = (options[:password] || options[:pass]).to_s
      end
    else
      self.load_environment! or self.load_credentials!
    end
    self.setup_socks_proxy!
  end

  ##
  # @private
  def self.load_environment!
    filepath = File.join(ENV['HOME'], '.dydra', 'environment')
    return false unless File.exists?(filepath)

    File.open(filepath, 'r') do |f|
      f.each_line do |line|
        case line
          when /^\s*#/ then next # skip comments
          when /^([A-Za-z_][A-Za-z0-9_]+)\s*=\s*(\S+)/
            ENV[$1] = $2 unless ENV.has_key?($1)
          else # TODO: error handling
        end
      end
    end
    true
  end

  ##
  # @deprecated
  # @private
  def self.load_credentials!
    filepath = File.join(ENV['HOME'], '.dydra', 'credentials')
    return false unless File.exists?(filepath)

    require 'yaml'
    yaml = YAML.load_file(filepath)
    ENV['DYDRA_ACCOUNT'] = yaml[:user] if yaml.has_key?(:user)
    ENV['DYDRA_PASSWORD'] = yaml[:password] if yaml.has_key?(:password)
    ENV['DYDRA_TOKEN'] = yaml[:token] if yaml.has_key?(:token)
    true
  end

  ##
  # @private
  def self.setup_socks_proxy!
    if (socks_server = ENV['SOCKS_SERVER']) && !socks_server.empty?
      begin
        host, port = socks_server.split(':', 2)
        require 'socksify' # @see http://rubygems.org/gems/socksify
        TCPSocket::socks_server = host
        TCPSocket::socks_port   = port.to_i
      rescue LoadError => e
        warn "WARNING: install the 'socksify' gem to use your configured SOCKS proxy (#{socks_server})." if $VERBOSE
      end
    end
  end
end # Dydra
