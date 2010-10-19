module Datagraph::Client
  ##
  # Represents a Datagraph.org RDF repository.
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$)

    attr_reader :account
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
    # Returns the number of RDF statements in this repository.
    def count
      to_rdf.size # TODO: optimize this.
    end

    ##
    # Returns a string representation of the repository name.
    def to_s
      [account.name, name].join('/')
    end
  end # Repository
end # Datagraph::Client
