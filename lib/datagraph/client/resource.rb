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
    # Returns the RDF data for this resource.
    def to_rdf
      get('.nt', 'Accept' => 'text/plain') do |response|
        case response
          when Net::HTTPSuccess
            reader = RDF::NTriples::Reader.new(response.body)
            reader.to_a.extend(RDF::Enumerable, RDF::Queryable) # FIXME
        end
      end
    end

    ##
    # Performs an HTTP GET request on this resource.
    #
    # @param  [String, #to_s]          format
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def get(format = nil, headers = {}, &block)
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.get(url.path.to_s + format.to_s, HEADERS.merge(headers))
        if block_given?
          block.call(response)
        else
          response
        end
      end
    end
  end # class Resource
end # module Datagraph::Client
