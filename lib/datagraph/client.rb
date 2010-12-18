module Datagraph
  ##
  # Datagraph.org API client library.
  module Client
    # what a mouthful.  
    # workaround for a bug in Rexml in 1.9.2
    # kou posted it in:
    # http://www.ruby-forum.com/topic/463233
    module XMLRPCUTF8Fix
      def do_rpc(request, async=false)
        data = super
        data.force_encoding("UTF-8") if data.respond_to?(:force_encoding)
        data
      end
    end
    ##
    # Returns a Datagraph.org RPC API client.
    #
    # @return [XMLRPC::Client]
    def self.rpc
      require 'xmlrpc/client' unless defined?(XMLRPC::Client)
      XMLRPC::Client.new2(Datagraph::URL.join('rpc')).extend(XMLRPCUTF8Fix) # defaults to XML-RPC for now
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
