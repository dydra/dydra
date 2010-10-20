module Datagraph::Client
  ##
  # Represents a Datagraph.org RDF repository.
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$) # /account/repository

    ##
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :account_name (nil)
    # @yield  [repository]
    # @yieldparam [Repository] repository
    # @return [Enumerator]
    def self.each(options = {}, &block)
      if block_given?
        result = Datagraph::Client.xmlrpc.call('datagraph.repository.list', options[:account_name] || '')
        result.each do |(account_name, repository_name)|
          block.call(Repository.new(account_name, repository_name))
        end
      end
      enum_for(:each, options)
    end

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
    # @return [Process]
    def create!
      Process.new(Datagraph::Client.xmlrpc.call('datagraph.repository.create', account.name, name))
    end

    ##
    # Destroys this repository from Datagraph.org.
    #
    # @return [Process]
    def destroy!
      Process.new(Datagraph::Client.xmlrpc.call('datagraph.repository.destroy', account.name, name))
    end

    ##
    # Deletes all data from this repository.
    #
    # @return [Process]
    def clear!
      Process.new(Datagraph::Client.xmlrpc.call('datagraph.repository.clear', account.name, name))
    end

    ##
    # Imports data from a URL into this repository.
    #
    # @param  [String, #to_s] url
    # @return [Process]
    def import!(url)
      Process.new(Datagraph::Client.xmlrpc.call('datagraph.repository.import', account.name, name, url.to_s))
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    def count
      Datagraph::Client.xmlrpc.call('datagraph.repository.count', account.name, name)
    end

    ##
    # Queries this repository.
    #
    # @param  [String] query
    # @return [Process]
    def query(query)
      Process.new(Datagraph::Client.xmlrpc.call('datagraph.repository.query', account.name, name, query.to_s))
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
