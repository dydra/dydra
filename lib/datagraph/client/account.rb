module Datagraph::Client
  ##
  # Represents a Datagraph.org user account.
  class Account < Resource
    SPEC = %r(^([^/]+)$)

    ##
    # Returns `true` if an account with the given `name` exists on
    # Datagraph.org.
    #
    # @param  [String, #to_s] name
    # @return [Boolean]
    def self.exists?(name)
      Account.new(name).exists?
    end

    attr_reader :name

    ##
    # @param  [String, #to_s] name
    def initialize(name)
      @name = name.to_s
      super(Datagraph::URL.join(@name))
    end

    ##
    # Returns the given repository belonging to this account.
    #
    # @param  [String, #to_s] name
    # @return [Repository]
    def repository(name)
      Repository.new(self, name)
    end

    ##
    # Returns a string representation of the account name.
    def to_s
      name
    end
  end # Account
end # Datagraph::Client
