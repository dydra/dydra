module Datagraph::Client
  ##
  # Represents a Datagraph.org user account.
  class Account < Resource
    SPEC = %r(^([^/]+)$)

    attr_reader :name

    ##
    # @param  [String, #to_s] name
    def initialize(name)
      @name = name.to_s
      super(Datagraph::URL.join(@name))
    end

    ##
    # Returns a string representation of the account name.
    def to_s
      name
    end
  end # class Account
end # module Datagraph::Client
