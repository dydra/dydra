require 'xmlrpc/client'

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
        url.user     = ENV['DYDRA_TOKEN']
        url.password = ''
      end
      XMLRPC::Client.new2(url) # defaults to XML-RPC for now
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
