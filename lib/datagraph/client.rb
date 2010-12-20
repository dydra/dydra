require 'xmlrpc/client'

module Datagraph
  ##
  # Datagraph.org API client library.
  module Client
    ##
    # Returns a Datagraph.org RPC API client.
    #
    # @return [XMLRPC::Client]
    def self.rpc
      XMLRPC::Client.new2(Datagraph::URL.join('rpc')) # defaults to XML-RPC for now
    end

    ##
    # @private
    # @return [void]
    def self.setup!(options = {})
      warn "WARNING: the DATAGRAPH_URL environment variable is not set." if ENV['DATAGRAPH_URL'].to_s.empty?
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
end # Datagraph

require 'datagraph/patches/xmlrpc'
