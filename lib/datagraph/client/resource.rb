require 'net/http'

module Datagraph::Client
  ##
  # Base class for Datagraph.org resources.
  class Resource
    HEADERS = {'Accept' => 'text/plain'} # N-Triples

    ##
    # @return [RDF::URI]
    attr_reader :url

    ##
    # @param  [RDF::URI, String] url
    def initialize(url)
      @url = RDF::URI.new(url)
    end

    ##
    # Returns the URL of this resource.
    #
    # @return [RDF::URI]
    def to_uri
      url
    end

    ##
    # Performs an HTTP GET request on this resource.
    #
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def get(headers = {}, &block)
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.get(url.path.to_s, HEADERS.merge(headers))
        if block_given?
          block.call(response)
        else
          response
        end
      end
    end
  end # class Resource
end # module Datagraph::Client
