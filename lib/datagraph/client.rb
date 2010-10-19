require 'xmlrpc/client'

module Datagraph
  ##
  # Datagraph.org API client library.
  module Client
    autoload :Resource,   'datagraph/client/resource'
    autoload :Account,    'datagraph/client/account'
    autoload :Repository, 'datagraph/client/repository'
    autoload :Query,      'datagraph/client/query'

    ##
    # Returns a Datagraph.org XML-RPC API client.
    #
    # @return [XMLRPC::Client]
    # @see    http://ruby-doc.org/stdlib/libdoc/xmlrpc/rdoc/classes/XMLRPC/Client.html
    def self.xmlrpc
      XMLRPC::Client.new2(Datagraph::URL.join('xmlrpc'))
    end
  end # Client
end # Datagraph
