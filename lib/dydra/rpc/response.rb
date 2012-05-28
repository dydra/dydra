# This is free and unencumbered software released into the public domain.

module Dydra::RPC
  ##
  # Represents a Dydra.com RPC response.
  class Response
    include Message

    ##
    # @param  [Integer, String, nil] id
    # @param  [Object] result
    def initialize(id, result = nil)
      @id = id
      @result = result
    end

    ##
    # The response result.
    #
    # @return [Object]
    attr_reader :result

    ##
    # (see Message#to_hash)
    def to_hash
      super.merge!(:result => self.result)
    end
  end # Response
end # Dydra::RPC
