require 'xmlrpc/client'
require 'rest_client'
require 'json'

module Dydra
  ##
  # Dydra.com API client library.
  module Client
    ##
    # Returns a Dydra.com RPC API client.
    #
    # @return [XMLRPC::Client]
    def self.rpc
      url = Dydra::URL.join('rpc')
      unless ENV['DYDRA_TOKEN'].to_s.empty?
        url = url.join("?auth_token=#{ENV['DYDRA_TOKEN']}")
      end
      XMLRPC::Client.new2(url) # defaults to XML-RPC for now
    end

    ##
    # Authenticate with dydra.com
    #
    # @return [Void]
    def self.authenticate!(options = {})
      $dydra ||= {}
      if options[:token]
        $dydra[:token] = options[:token]
      elsif options[:user]
        $dydra[:user] = options[:user]
        $dydra[:pass] = options[:password] || options[:pass] || raise(AuthenticationError, "You must supply a password")
      elsif ENV['DYDRA_TOKEN']
        $dydra[:token] = ENV['DYDRA_TOKEN']
      elsif File.exists?(credentials_file)
        require 'yaml'
        $dydra.merge!(YAML.load_file(credentials_file))
        if !$dydra[:user] && !($dydra[:pass] || $dydra[:token])
          raise AuthenticationError, "You need to specify :user and :pass or :token in #{credentials_file}"
        end
      else
        raise AuthenticationError, "You need to give either :user and :password, or :token, or set your ENV['DYDRA_TOKEN'] to authenticate."
      end
    end


    ##
    # GET parsed json from the dydra.com REST API
    # @param [String] where
    # @param [Hash] additional options
    # @return [Any]
    def self.get_json(where, options = {})
      JSON.parse(get(where, options))
    end

    ##
    # GET from the dydra.com REST API
    # 
    # @param [String] where
    # @return [Any]
    def self.get(where, options = {})
      resource(where).get({ :accept => :json }.merge(options))
    end

    ##
    # DELETE from the dydra.com REST API
    # 
    # @param [String] where
    # @return [Any]
    def self.delete(where)
      resource(where).delete
    end

    ##
    # POST to the Dydra.com REST API
    #
    # @return [Any]
    def self.post(where, what, options = {})
      what = what.to_json unless options[:content_type]
      resource(where).post what, { :content_type => 'application/json' }.merge(options)
    end

    ##
    # Provides a RestClient::Resource configured with authentication
    # information for the given URL fragment
    #
    # @return [RestClient::Resource]
    def self.resource(location)
      if $dydra[:token]
        RestClient::Resource.new Dydra::URL.join(location).to_s, $dydra[:token]
      elsif $dydra[:user]
        RestClient::Resource.new(Dydra::URL.join(location).to_s, :user => $dydra[:user], :password => $dydra[:pass])
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
      $dydra[:setup?] = true
    end

    ##
    # Returns true if setup has been run
    #
    # @return [Boolean]
    def self.setup?
      $dydra ||= {}
      $dydra[:setup?]
    end

    ##
    # Clear the current user state
    def self.reset!
      $dydra = {}
    end

    ##
    # The file which we'll read and write credentials to
    def self.credentials_file
      File.join(ENV['HOME'], '.dydra', 'credentials')
    end

  end # Client
end # Dydra

require 'dydra/patches/xmlrpc'
