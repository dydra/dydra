# This is free and unencumbered software released into the public domain.

require 'xmlrpc/client'
require 'rest_client'   # @see http://rubygems.org/gems/rest-client
require 'json'          # @see http://rubygems.org/gems/json

module Dydra
  module Client
    ##
    # Returns a Dydra.com RPC API client.
    #
    # @deprecated
    # @return [XMLRPC::Client]
    def self.rpc
      warn "WARNING: using the deprecated RPC interface..."
      url = Dydra::URL.host.to_s.sub(/\/$/, '')
      port = Dydra::URL.port || 80
      if ENV['DYDRA_TOKEN']
        XMLRPC::Client.new3('host' => url, 'port' => port, 'path' => "/rpc?auth_token=#{ENV['DYDRA_TOKEN']}")
      elsif ENV['DYDRA_ACCOUNT']
        XMLRPC::Client.new3('host' => url, 'port' => port, 'path' => '/rpc', 'user' => ENV['DYDRA_ACCOUNT'], 'password' => ENV['DYDRA_PASSWORD'])
      else
        raise AuthenticationError, "You need to run Dydra.setup! before performing an API operation"
      end
    end

    ##
    # GET parsed JSON from the Dydra.com REST API.
    #
    # @param  [String] where
    # @param  [Hash{Symbol => Object}]
    #   any additional options
    # @return [Hash]
    def self.get_json(where, options = {})
      JSON.parse(get(where, options))
    end

    ##
    # GET from the Dydra.com REST API.
    #
    # @param  [String] where
    # @param  [Hash{Symbol => Object}]
    #   any additional options
    # @return [Object]
    def self.get(where, options = {})
      resource(where).get({:accept => :json, :user_agent => "Dydra API client #{Dydra::VERSION}"}.merge(options))
    end

    ##
    # DELETE from the Dydra.com REST API.
    #
    # @param  [String] where
    # @return [Object]
    def self.delete(where)
      resource(where).delete({:user_agent => "Dydra API client #{Dydra::VERSION}"})
    end

    ##
    # POST to the Dydra.com REST API.
    #
    # @param  [String] where
    # @param  [Hash{Symbol => Object}]
    #   any additional options
    # @return [Object]
    def self.post(where, what, options = {})
      what = what.to_json unless options[:content_type]
      resource(where).post(what, {:content_type => 'application/json', :user_agent => "Dydra API client #{Dydra::VERSION}"}.merge(options))
    end

    ##
    # Provides a `RestClient::Resource` configured with authentication
    # information for the given URL fragment.
    #
    # @param  [String] location
    # @return [RestClient::Resource]
    def self.resource(location)
      opts = {}
      opts[:timeout] = ENV['DYDRA_REQUEST_TIMEOUT'].to_i if ENV['DYDRA_REQUEST_TIMEOUT']
      if ENV['DYDRA_TOKEN']
        RestClient::Resource.new(Dydra::URL.join(location).to_s, opts.merge(:user => ENV['DYDRA_TOKEN']))
      elsif ENV['DYDRA_ACCOUNT']
        RestClient::Resource.new(Dydra::URL.join(location).to_s, opts.merge(:user => ENV['DYDRA_ACCOUNT'], :password => ENV['DYDRA_PASSWORD']))
      else
        raise AuthenticationError, "You need to run Dydra.setup! before performing an API operation"
      end
    end
  end # Client
end # Dydra
