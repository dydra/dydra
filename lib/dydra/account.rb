module Dydra
  ##
  # Represents a Dydra.com user account.
  #
  # @example Enumerating repositories belonging to an account
  #   account.each_repository do |repository|
  #     puts repository.inspect
  #   end
  #
  # @example Accessing a repository belonging to an account
  #   repository = account[:foaf]
  #
  class Account < Resource
    include Enumerable

    SPEC = %r(^([^/]+)$) # /account

    ##
    # Returns `true` if an account with the given `name` exists on
    # Dydra.com.
    #
    # @param  [String, #to_s] name
    # @return [Boolean]
    def self.exists?(name)
      Account.new(name).exists?
    end

    ##
    # Registers a new user account with Dydra.com.
    #
    # @param  [String] name
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :email
    # @option options [String] :password
    # @return [Account]
    def self.register!(name, options = {})
      Dydra::Client.rpc.call('dydra.account.register', name, options[:email], options[:password]) # FIXME
      self.new(name)
    end

    # @return [String]
    attr_reader :name

    ##
    # @param  [String, #to_s] name
    def initialize(name)
      @name = name.to_s
      super(Dydra::URL.join(@name))
    end

    ##
    # Returns basic account info.
    #
    # @return [Hash]
    def info
      Dydra::Client.get_json(name)
    end

    ##
    # Returns the given repository belonging to this account.
    #
    # @param  [String, #to_s] name
    # @return [Repository]
    def repository(name)
      Repository.new(self, name)
    end
    alias_method :[], :repository

    ##
    # Returns the list of repositories belonging to this account.
    #
    # @return [Array<Repository>]
    def repositories
      each_repository.to_a
    end

    ##
    # Enumerates each repository belonging to this account.
    #
    # @yield  [repository]
    # @yieldparam  [Repository] repository
    # @yieldreturn [void]
    # @return [Enumerator]
    # @since  0.0.4
    def each_repository(options = {}, &block)
      if block_given?
        result = Dydra::Client.rpc.call('dydra.repository.list', name)
        result.each do |(account_name, repository_name)|
          block.call(Repository.new(account_name, repository_name))
        end
      end
      enum_for(:each_repository, options)
    end
    alias_method :each, :each_repository

    ##
    # Returns a string representation of the account name.
    #
    # @return [String]
    def to_s
      name
    end
  end # Account
end # Dydra
