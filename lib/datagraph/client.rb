module Datagraph
  ##
  # Datagraph.org API client library.
  module Client
    autoload :Resource,   'datagraph/client/resource'
    autoload :Account,    'datagraph/client/account'
    autoload :Process,    'datagraph/client/process'
    autoload :Repository, 'datagraph/client/repository'
    autoload :Query,      'datagraph/client/query'

    ##
    # Returns a Datagraph.org RPC API client.
    #
    # @return [XMLRPC::Client]
    def self.rpc
      require 'xmlrpc/client' unless defined?(XMLRPC::Client)
      XMLRPC::Client.new2(Datagraph::URL.join('rpc')) # defaults to XML-RPC for now
    end
  end # Client
end # Datagraph
