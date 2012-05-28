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
    # The number of times to retry idempotent RPC requests in case of a
    # terminated connection to the RPC endpoint.
    RECONNECT_COUNT = 1

    ##
    # Returns the `User-Agent` header to send with RPC requests.
    #
    # @return [String]
    def self.user_agent
      USER_AGENT.freeze
    end

    ##
    # Invokes an RPC operation on the server.
    #
    # @param  [Symbol, #to_s] operator
    # @param  [Hash, Array, #to_a] operands
    # @yield  [result]
    # @yieldparam  [Object] result
    # @yieldreturn [void]
    # @return [Object] the result
    def self.call(operator, operands)
      self.new.call(operator, operands)
    end

    ##
    # @param  [#to_s] base_url
    # @param  [Hash] options
    def initialize(base_url = Dydra::URL, options = nil)
      # TODO: support authentication.
      @url = RDF::URI(base_url) / "/rpc/#{Protocol::API_VERSION}"
      @options = options || {}
    end

    ##
    # Any additional options.
    #
    # @return [Hash]
    attr_reader :options

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
    # The HTTP client instance used to communicate with the RPC endpoint.
    #
    # @return [Net:HTTP] the HTTP client
    # @!parse attr_reader :http
    def http
      @http ||= begin
        http = Net::HTTP.new(self.host, self.port)
        http.set_debug_output($stderr) if self.options[:debug]
        http
      end
    end

    ##
    # Checks whether the connection to the RPC endpoint is active.
    #
    # @return [Boolean]
    def connected?
      (self.http && self.http.started?) || false
    end

    ##
    # Establishes the connection to the RPC endpoint.
    #
    # @yield  [client]
    # @yieldparam  [Client] client `self`
    # @yieldreturn [void]
    # @return [void] `self`
    def connect(&block)
      self.http.start unless self.http.started?
      if block_given?
        block.call
      else
        self
      end
    end
    alias_method :connect!, :connect

    ##
    # Terminates the connection from the RPC endpoint.
    #
    # @return [void] `self`
    def disconnect
      if self.http
        begin
          self.http.finish if self.http.started?
        rescue IOError
        end
      end
      self
    end
    alias_method :disconnect!, :disconnect

    ##
    # Invokes an RPC operation on the server.
    #
    # @param  [Symbol, #to_s] operator
    # @param  [Hash, Array, #to_a] operands
    # @yield  [result]
    # @yieldparam  [Object] result
    # @yieldreturn [void]
    # @return [Object] the result
    def call(operator, operands = nil, &block)
      request  = Request.new(nil, operator, operands)
      response = execute_with_reconnect(request)
      case response
        when Error    then raise response
        when Response then response.result
      end
    end

    ##
    # @private
    def execute_with_reconnect(request, &block)
      reconnect_count = 0
      begin
        execute(request, &block)
      rescue EOFError, Errno::ECONNRESET => e
        if request.idempotent? && reconnect_count < RECONNECT_COUNT
          reconnect_count += 1
          self.http.finish
          self.http.start
          retry
        else
          raise
        end
      end
    end

    ##
    # Executes the given RPC request on the server.
    #
    # @param  [Request] the client request
    # @yield  [response]
    # @yieldparam  [Response] response the server response
    # @yieldreturn [void]
    # @return [Response] the server response
    def execute(request, &block)
      data = Message.serialize(request)
      connect do
        case http_response = self.http.post(self.path, data, self.headers)
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

    ##
    # Returns a developer-friendly representation of this RPC client.
    #
    # @return [String]
    def inspect
      Kernel.sprintf("#<%s:%#0x(%s)>", self.class.name, self.__id__, self.url.to_s)
    end

    ##
    # Outputs a developer-friendly representation of this RPC client to the
    # standard error stream.
    #
    # @return [void]
    def inspect!
      Kernel.warn(self.inspect)
    end
  end # Client
end # Dydra::RPC
