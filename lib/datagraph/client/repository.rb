module Datagraph::Client
  ##
  # Represents a Datagraph.org RDF repository.
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$)

    # @return [Account]
    attr_reader :account

    # @return [String]
    attr_reader :name

    ##
    # @param  [String, #to_s] account_name
    # @param  [String, #to_s] name
    def initialize(account_name, name)
      @account = case account_name
        when Account then account_name
        else Account.new(account_name.to_s)
      end
      @name = name.to_s
      super(Datagraph::URL.join(@account.name, @name))
    end

    ##
    # Creates this repository on Datagraph.org.
    #
    # @return [void]
    def create!
      Datagraph::Client.xmlrpc.call('datagraph.repository.create', account.name, name)
    end

    ##
    # Destroys this repository from Datagraph.org.
    #
    # @return [void]
    def destroy!
      Datagraph::Client.xmlrpc.call('datagraph.repository.delete', account.name, name)
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    def count
      Datagraph::Client.xmlrpc.call('datagraph.repository.count', account.name, name)
    end

    ##
    # Returns a string representation of the repository name.
    #
    # @return [String]
    def to_s
      [account.name, name].join('/')
    end
  end # Repository
end # Datagraph::Client
