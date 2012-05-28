# This is free and unencumbered software released into the public domain.

module Dydra::RPC
  ##
  # Represents a Dydra.com RPC request.
  class Request
    include Message

    ##
    # Returns a unique request identifier.
    #
    # This class maintains an internal monotonically-increasing integer
    # identifier that gets incremented each time this method is invoked.
    # It is safe to call this method concurrently from multiple threads.
    #
    # @return [Integer] an integer greater than or equal to 1
    def self.id
      @mutex ||= Mutex.new
      @mutex.synchronize do
        @id ||= 0
        @id += 1
      end
    end

    ##
    # @param  [Integer, String, nil] id
    # @param  [Symbol, #to_s] operator
    # @param  [Hash, Array, #to_a] operands
    def initialize(id, operator, operands = nil)
      @id = id || self.class.id
      @operator = operator
      @operands = operands || []
    end

    ##
    # The request operator.
    #
    # @return [Symbol]
    attr_reader :operator

    ##
    # The request operands.
    #
    # @return [Array]
    attr_reader :operands

    ##
    # (see Message#to_hash)
    def to_hash
      super.merge!({
        :method => self.operator.to_s,
        :params => self.operands.is_a?(Hash) ? self.operands : self.operands.to_a,
      })
    end
  end # Request
end # Dydra::RPC
