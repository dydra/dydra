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
    # Returns `true` if this account exists on Datagraph.org.
    #
    # @return [Boolean]
    def exists?
      get do |response|
        case response
          when Net::HTTPSuccess     then true
          when Net::HTTPClientError then false
          else true # FIXME: dubious default, for now
        end
      end
    end

    ##
    # Returns a string representation of the account name.
    def to_s
      name
    end
  end # class Account
end # module Datagraph::Client
