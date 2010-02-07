module Datagraph::Client
  ##
  # Base class for Datagraph.org resources.
  class Resource
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
  end # class Resource
end # module Datagraph::Client
