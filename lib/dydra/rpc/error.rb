# This is free and unencumbered software released into the public domain.

module Dydra::RPC
  ##
  # Represents a Dydra.com RPC error condition.
  class Error < IOError
    include Message

    ##
    # @param  [Integer, String, nil] id
    # @param  [Integer, #to_i] code
    # @param  [String, #to_s] message
    # @param  [Object] data
    def initialize(id, code, message, data = nil)
      @id = id
      @code = code
      @message = message
      @data = data
      super(message)
    end

    ##
    # The error code.
    #
    # @return [Integer]
    attr_reader :code

    ##
    # The error message.
    #
    # @return [String]
    attr_reader :message

    ##
    # Any extra error information.
    #
    # @return [Object]
    attr_reader :data

    ##
    # (see Message#to_hash)
    def to_hash
      super.merge!(:error => {
        :code    => self.code.to_i,
        :message => self.message.to_s,
        :data    => self.data,
      })
    end
  end # Error
end # Dydra::RPC
