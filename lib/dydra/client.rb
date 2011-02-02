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
    # Post to the Dydra.com REST API
    #
    # @return [Any]
    def self.post where, what, options = {}
      what = what.to_json unless options[:content_type]
      resource(where).post what, { :content_type => 'application/json' }.merge(options)
    end

    def self.resource(location)
      if ENV['DYDRA_TOKEN']
        RestClient::Resource.new Dydra::URL.join(location).to_s, ENV['DYDRA_TOKEN']
      elsif ENV['DYDRA_USER']
        RestClient::Resource.new Dydra::URL.join(location).to_s, ENV['DYDRA_USER'], ENV['DYDRA_PASS']
      end
    end

    ##
    # @private
    # @return [void]
    def self.setup!(options = {})
      #warn "WARNING: the DYDRA_URL environment variable is not set." if ENV['DYDRA_URL'].to_s.empty?
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
    end
  end # Client
end # Dydra

require 'dydra/patches/xmlrpc'
