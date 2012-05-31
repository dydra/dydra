# This is free and unencumbered software released into the public domain.

require 'xmlrpc/client'
require 'rest_client'   # @see http://rubygems.org/gems/rest-client
require 'json'          # @see http://rubygems.org/gems/json

module Dydra
  ##
  # Implements a Dydra.com XML-RPC API client.
  #
  # @see http://docs.dydra.com/sdk/ruby
  # @see http://docs.dydra.com/api/rpc
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
    # Authenticates with Dydra.com.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :token    (nil)
    # @option options [String] :user     (nil)
    # @option options [String] :password (nil)
    # @return [void]
    def self.authenticate!(options = {})
      if options[:token]
        ENV['DYDRA_TOKEN'] = options[:token]
      elsif options[:user]
        ENV['DYDRA_ACCOUNT'] = options[:user]
        ENV['DYDRA_PASSWORD'] = options[:password] || options[:pass] || raise(AuthenticationError, "You must supply a password")
      elsif File.exists?(credentials_file)
        require 'yaml'
        yaml = YAML.load_file(credentials_file)
        ENV['DYDRA_ACCOUNT'] = yaml[:user] if yaml.has_key?(:user)
        ENV['DYDRA_PASSWORD'] = yaml[:password] if yaml.has_key?(:password)
        ENV['DYDRA_TOKEN'] = yaml[:token] if yaml.has_key?(:token)
        if !ENV['DYDRA_ACCOUNT'] && !(ENV['DYDRA_PASSWORD'] || ENV['DYDRA_TOKEN'])
          raise AuthenticationError, "You need to specify :user and :pass or :token in #{credentials_file}"
        end
      else
        raise AuthenticationError, "You need to give either :user and :password, or :token, or set your ENV['DYDRA_TOKEN'] to authenticate."
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

    ##
    # @private
    # @return [void]
    def self.setup!(options = {})
      authenticate!(options)
      if (socks_server = ENV['SOCKS_SERVER']) && !socks_server.empty?
        begin
          host, port = socks_server.split(':', 2)
          require 'socksify' # @see http://rubygems.org/gems/socksify
          TCPSocket::socks_server = host
          TCPSocket::socks_port   = port.to_i
          nil
        rescue LoadError => e
          warn "WARNING: install the 'socksify' gem to use your configured SOCKS proxy (#{socks_server})." if $VERBOSE
        end
      end
    end

    ##
    # Returns `true` if `#setup!` has been run.
    #
    # @return [Boolean] `true` or `false`
    def self.setup?
      true # FIXME
    end

    ##
    # Clears the current user state.
    #
    # @return [void]
    def self.reset!
      # TODO
    end

    ##
    # Returns the path of the file which we'll read and write credentials
    # to.
    #
    # @return [String]
    def self.credentials_file
      File.join(ENV['HOME'], '.dydra', 'credentials') # FIXME
    end
  end # Client
end # Dydra
