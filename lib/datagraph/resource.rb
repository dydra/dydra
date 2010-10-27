require 'net/http'

module Datagraph
  ##
  # Base class for Datagraph.org resources.
  class Resource
    HEADERS = {'Accept' => 'text/plain'} # N-Triples

    include Comparable

    def self.new(*args, &block)
      if self == Resource
        case spec = args.first
          when Repository::SPEC
            Repository.new(*spec.split('/'))
          when Account::SPEC
            Account.new(spec)
        end
      else
        super
      end
    end

    ##
    # @return [RDF::URI]
    attr_reader :url

    ##
    # @param  [RDF::URI, String] url
    def initialize(url)
      @url = RDF::URI.new(url)
    end

    ##
    # Returns the root-relative path of this resource.
    #
    # @return [String]
    def path
      url.path[1..-1]
    end

    ##
    # Returns `true` if this resource exists on Datagraph.org.
    #
    # @return [Boolean]
    def exists?
      head do |response|
        case response
          when Net::HTTPSuccess     then true
          when Net::HTTPClientError then false
          else true # FIXME: dubious default, for now
        end
      end
    end

    ##
    # Returns `true` if this resource is equal to the given `other`
    # resource.
    #
    # @param  [Object] other
    # @return [Boolean]
    def eql?(other)
      other.class.eql?(self.class) && self == other
    end

    ##
    # Compares this resources to the given `other` resource.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    def <=>(other)
      self.to_uri <=> other.to_uri
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
    # Returns a developer-friendly representation of this resource.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, object_id, to_s)
    end

    ##
    # Outputs a developer-friendly representation of this resource to
    # `stderr`.
    #
    # @return [void]
    def inspect!
      warn(inspect)
    end

    ##
    # Performs an HTTP HEAD request on this resource.
    #
    # @param  [String, #to_s]          format
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def head(format = nil, headers = {}, &block)
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.head(url.path.to_s + format.to_s, HEADERS.merge(headers))
        if block_given?
          block.call(response)
        else
          response
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
  end # Resource
end # Datagraph
