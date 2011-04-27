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
    # @return [XMLRPC::Client]
    def self.rpc
      url = Dydra::URL.host.to_s.sub(/\/$/, '')
      port = Dydra::URL.port || 80
      $dydra ||= {}
      if $dydra[:token]
        XMLRPC::Client.new3('host' => url, 'port' => port, 'path' => "/rpc?auth_token=#{$dydra[:token]}")
      elsif $dydra[:user]
        XMLRPC::Client.new3('host' => url, 'port' => port, 'path' => '/rpc', 'user' => $dydra[:user], 'password' => $dydra[:pass])
      else
        raise AuthenticationError, "You need to run Dydra::Client.setup! before performing an API operation"
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
      $dydra ||= {}
      if options[:token]
        $dydra[:token] = options[:token]
      elsif options[:user]
        $dydra[:user] = options[:user]
        $dydra[:pass] = options[:password] || options[:pass] || raise(AuthenticationError, "You must supply a password")
      elsif File.exists?(credentials_file)
        require 'yaml'
        $dydra.merge!(YAML.load_file(credentials_file))
        if !$dydra[:user] && !($dydra[:pass] || $dydra[:token])
          raise AuthenticationError, "You need to specify :user and :pass or :token in #{credentials_file}"
        end
      elsif ENV['DYDRA_TOKEN']
        $dydra[:token] = ENV['DYDRA_TOKEN']
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
      $dydra ||= {}
      opts = {}
      opts[:timeout] = ENV['DYDRA_REQUEST_TIMEOUT'].to_i if ENV['DYDRA_REQUEST_TIMEOUT']
      if $dydra[:token]
        RestClient::Resource.new(Dydra::URL.join(location).to_s, opts.merge(:user => $dydra[:token]))
      elsif $dydra[:user]
        RestClient::Resource.new(Dydra::URL.join(location).to_s, opts.merge(:user => $dydra[:user], :password => $dydra[:pass]))
      else
        raise AuthenticationError, "You need to run Dydra::Client.setup! before performing an API operation"
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
          warn "WARNING: install the 'socksify' gem to use your configured SOCKS proxy (#{socks_server})."
        end
      end
      $dydra ||= {}
      $dydra[:setup?] = true
    end

    ##
    # Returns `true` if `#setup!` has been run.
    #
    # @return [Boolean] `true` or `false`
    def self.setup?
      $dydra ||= {}
      $dydra[:setup?]
    end

    ##
    # Clears the current user state.
    #
    # @return [void]
    def self.reset!
      $dydra = {}
    end

    ##
    # Returns the path of the file which we'll read and write credentials
    # to.
    #
    # @return [String]
    def self.credentials_file
      File.join(ENV['HOME'], '.dydra', 'credentials')
    end
  end # Client
end # Dydra

require 'dydra/patches/xmlrpc'
