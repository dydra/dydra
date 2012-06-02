# This is free and unencumbered software released into the public domain.

require 'json'

module Dydra::RPC
  ##
  # Base functionality for Dydra.com RPC messages.
  module Message
    include Dydra::Inspectable

    CONTENT_TYPE = 'application/json; charset=UTF-8'.freeze

    ##
    # Parses a serialized RPC message, returning an instance of the
    # appropriate class (request, response, or error condition).
    #
    # @param  [String, #to_s] input the serialized message data
    # @return [Message] the parsed message
    # @raise  [TypeError] if the input could not be parsed
    def self.parse(input)
      json = JSON.parse(input.to_s)
      case
        when json.has_key?('method')
          Request.new(json['id'], json['method'], json['params'])
        when json.has_key?('result')
          Response.new(json['id'], json['result'])
        when json.has_key?('error')
          Error.new(json['id'], json['code'], json['message'], json['data'])
        else
          raise TypeError, "failed to parse #{input.inspect}"
      end
    end

    ##
    # Serializes an RPC message.
    #
    # @param  [Message] message the message to serialize
    # @return [String] the serialized message data
    def self.serialize(message)
      message.to_json
    end

    ##
    # The message protocol version.
    #
    # @return [Float] by default `2.0`
    # @!parse attr_reader :version
    def version
      @version ||= Protocol::JSONRPC_VERSION
    end

    ##
    # The message identifier.
    #
    # @return [Object] a number, string, or `nil`
    attr_reader :id

    ##
    # Determines whether this RPC message is idempotent.
    #
    # @return [Boolean]
    def idempotent?
      false # a safe default
    end

    ##
    # Returns a string representation of this RPC message.
    #
    # @return [String]
    def to_s
      self.to_json
    end

    ##
    # Returns the JSON string representation of this RPC message.
    #
    # @return [String]
    def to_json
      self.to_hash.delete_if { |k, v| !(k.eql?(:id)) && v.nil? }.to_json
    end

    ##
    # Returns the JSON hash representation of this RPC message.
    #
    # @return [Hash]
    def to_hash
      {:jsonrpc => self.version.to_s, :id => self.id}
    end
  end # Message
end # Dydra::RPC
