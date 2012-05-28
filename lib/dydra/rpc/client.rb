# This is free and unencumbered software released into the public domain.

require 'net/http'

module Dydra::RPC
  ##
  # Implements an RPC client for Dydra.com.
  class Client
    ##
    # The `User-Agent` header to send with RPC requests.
    USER_AGENT = "Dydra/#{Dydra::VERSION} (Ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"

    ##
    # Returns the `User-Agent` header to send with RPC requests.
    #
    # @return [String]
    def self.user_agent
      USER_AGENT.freeze
    end

    ##
    # @param  [#to_s] base_url
    def initialize(base_url = Dydra::URL)
      # TODO: support authentication.
      @url = RDF::URI(base_url) / "/rpc/#{Protocol::API_VERSION}"
    end

    ##
    # The RPC endpoint URL.
    #
    # @return [RDF::URI]
    attr_reader :url

    ##
    # Returns `true` unless this is an HTTPS connection.
    #
    # @return [Boolean]
    def insecure?
      !(self.secure?)
    end

    ##
    # Returns `true` if this is an HTTPS connection.
    #
    # @return [Boolean]
    def secure?
      self.protocol.eql?(:https)
    end

    ##
    # The RPC transport protocol.
    #
    # @return [Symbol] `:http` or `:https`
    # @!parse attr_reader :protocol
    def protocol
      @url.scheme.to_sym
    end

    ##
    # The RPC endpoint's host name.
    #
    # @return [String]
    # @!parse attr_reader :host
    def host
      @url.host
    end

    ##
    # The RPC endpoint's port number.
    #
    # @return [Integer]
    # @!parse attr_reader :port
    def port
      @url.port || (self.secure? ? 443 : 80)
    end

    ##
    # The RPC endpoint's request path.
    #
    # @return [String]
    # @!parse attr_reader :path
    def path
      @url.path.to_s
    end

    ##
    # The HTTP headers to send with RPC requests.
    #
    # @return [Hash]
    # @!parse attr_reader :headers
    def headers
      @headers ||= begin
        {
          'User-Agent'   => Client.user_agent,
          'Content-Type' => Message::CONTENT_TYPE,
        }
      end
    end

    ##
    # Invokes an RPC operation on the server.
    #
    # @param  [Symbol, #to_s] operator
    # @param  [Hash, Array, #to_a] operands
    # @yield  [result]
    # @yieldparam [Object] result
    # @return [Object] the result
    def call(operator, operands = nil, &block)
      request  = Request.new(nil, operator, operands)
      response = execute(request)
      case response
        when Error    then raise response
        when Response then response.result
      end
    end

    ##
    # Executes the given RPC request on the server.
    #
    # @param  [Request] the client request
    # @yield  [response]
    # @yieldparam [Response] response the server response
    # @return [Response] the server response
    def execute(request, &block)
      data = Message.serialize(request)
      Net::HTTP.start(self.host, self.port) do |http|
        case http_response = http.post(self.path, data, self.headers)
          when Net::HTTPSuccess
            response = Message.parse(http_response.body)
            if block_given?
              block.call(response)
            else
              response
            end
          else http_response.error!
        end
      end
    end
  end # Client
end # Dydra::RPC
