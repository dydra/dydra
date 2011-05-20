module Dydra
  ##
  # Represents a Dydra.com RDF repository.
  #
  # @see http://docs.dydra.com/sdk/ruby
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$) # /account/repository

    FORMATS = { :json     => 'application/sparql-results+json',
                :xml      => 'application/sparql-results+xml',
                :columns  => 'application/json',
                :rdf      => 'application/rdf+xml',
                :sse      => 'application/sparql-query+sse',
                :ntriples => 'text/plain',
                :n3       => 'text/rdf+n3',
                :turtle   => 'text/turtle' }


    ##
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :account_name (nil)
    # @yield  [repository]
    # @yieldparam [Repository] repository
    # @return [Enumerator]
    def self.each(options = {}, &block)
      if block_given?
        result = Dydra::Client.rpc.call('dydra.repository.list', $dydra[:user] || '')
        result.each do |(account_name, repository_name)|
          block.call(Repository.new(account_name, repository_name))
        end
      end
      enum_for(:each, options)
    end

    ##
    # The account the repository belongs to.
    #
    # @return [Account]
    attr_reader :account

    ##
    # The machine-readable name of the repository.
    #
    # @return [String]
    attr_reader :name

    ##
    # The short description of the repository.
    #
    # @return [String]
    attr_reader :summary

    ##
    # The long description of the repository.
    #
    # @return [String]
    attr_reader :description

    ##
    # When the repository was first created.
    #
    # @return [DateTime]
    attr_reader :created

    ##
    # When the repository was last updated.
    #
    # @return [DateTime]
    attr_reader :updated

    [:summary, :description, :created, :updated].each do |property|
      class_eval(<<-EOS)
        def #{property}(); info['#{property}']; end
      EOS
    end

    ##
    # @param  [String, #to_s] user
    # @param  [String, #to_s] name
    def initialize(user, name = nil)
      if name.nil?
        if user =~ /\// # a user/repo form
          (user, name) = user.split(/\//)
        else
          name = user
          user = $dydra[:user]
        end
      end
      if user.nil? && !$dydra[:token].nil?
        raise RepositoryMisspecified, "You must specify a repository owner name when using token-only authentication"
      end
      @account = case user
        when Account then user
        else Account.new(user.to_s)
      end
      @name = name.to_s
      if Dydra::URL.respond_to?(:'/')
        super(Dydra::URL / @account.name / @name)    # RDF.rb 0.3.0+
      else
        super(Dydra::URL.join(@account.name, @name)) # RDF.rb 0.2.x
      end
    end

    ##
    # Sugar for creating a repository, as `.new` instantiates an existing one.
    #
    # @param  [String] repository_name
    # @return [Repository]
    def self.create!(account, name = nil)
      self.new(account, name).create!
    end

    ##
    # List of repository names. Will use the given user if supplied.
    #
    # @param  [String] account
    # @return [Array<String>]
    def self.list(user = nil)
      user ||= $dydra[:user]
      raise RepositoryMisspecified, "List requires a user in token-only authentication mode" if user.nil?
      Dydra::Client.get_json(user + '/repositories').map { |r| r['name'] }
    end

    ##
    # Creates this repository on Dydra.com.
    #
    # @return [void]
    def create!
      Dydra::Client.post("#{account}/repositories", { :repository => { :name => name }})
    end

    ##
    # Destroys this repository from Dydra.com.
    #
    # @return [Job]
    def destroy!
      Dydra::Client.delete("#{@account}/#{@name}")
    end

    ##
    # Deletes all data in this repository.
    #
    # @return [Job]
    def clear!
      # FIXME: server is not async for this method yet.
      Dydra::Client.rpc.call('dydra.repository.clear', path)
    end

    ##
    # Insert RDF data into this repository
    #
    def insert(*statements)
      Dydra::Client.post "repositories/#{@account}/#{@name}/statements",
                         RDF::Writer.for(:ntriples).dump(statements),
                         :content_type => 'text/plain'

    end


    ##
    # Imports data from a URL into this repository.
    #
    # @param  [String, #to_s] url
    # @return [Job]
    def import!(url, opts = {})
      base_uri = opts[:base_uri] # || File.dirname(url)
      context = opts[:context] || ''
      if url =~ %r(^(http|https|ftp )://)
        url = url                                     # already a url
        base_uri = opts[:base_uri] || ''              # let the server determine base URI
      else
        base_uri = opts[:base_uri] || url             # Base URI is the file itself unless specified
        url = upload_local_file(self, url)            # local file to be uploaded
      end
      Job.new(Dydra::Client.rpc.call('dydra.repository.import', path, url.to_s, context.to_s, base_uri.to_s))
    end

    ##
    # Returns params necessary to generate an S3 upload form
    #
    # @return [Hash]
    def s3_upload_params
      Dydra::Client.rpc.call('dydra.repository.upload.params', path)
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    def count
      Dydra::Client.rpc.call('dydra.repository.count', path)
    end

    ##
    # Queries this repository.
    #
    # @param  [String] query
    # @return [Job]
    def query(query, opts = {})
      form = self.class.query_form(query)
      format = opts[:format] || case form
          when :select, :ask
            :json
          when :construct, :describe
            :ntriples
      end
      accept = case
        when FORMATS.has_key?(format)
          FORMATS[format]
        when :parsed
          case form
            when :select, :ask
              FORMATS[:columns]
            when :construct, :describe
              FORMATS[:ntriples]
          end
        else
          raise ArgumentError, "Unknown result format: #{format}"
      end

      begin

        result = Dydra::Client.post "#{account}/#{name}/sparql", { :query => query },
           :content_type => 'application/x-www-form-urlencoded',
           :accept => accept

      # Query failure messages should come back JSON encoded. If we can't parse
      # the response as JSON, some other error was raised on the server that we
      # supress here.
      rescue Exception => e
        begin
          puts JSON.parse(e.response)['error']
          exit
        rescue
          puts "A server error was encountered."
          exit
        end
      end

      return result unless format == :parsed
      case form
        when :select, :ask
          parse_bindings(result)
        when :construct, :describe
          parse_rdf(result)
      end
    end

    ##
    # Parse ASK or SELECT bindings into true/false or RDF::Query::Solutions
    #
    # @return [true, false, RDF::Query::Solutions]
    def parse_bindings(result)
      results = JSON.parse(result)
      variables = results["columns"].map(&:to_sym)
      nodes = {}
      bindings = results["rows"].map do | row |
        solution = RDF::Query::Solution.new        
        row.each_with_index do | binding, index |
          solution[variables[index]] = parse_json_value(binding, nodes)
        end
        solution
      end

      if results["total"] == 1 &&  bindings.first.respond_to?(:result) && [true, false].include?(bindings.first.result.object)
        bindings.first.result.object
      else
        bindings
      end
    end

    ##
    # Parse JSON column result values
    def parse_json_value(value, nodes = {})
      # This catches successful queries with no bound variables
      return nil unless value['type']
      case value['type'].to_sym
        when :bnode
          nodes[id = value['value']] ||= RDF::Node.new(id)
        when :uri
          RDF::URI.new(value['value'])
        when :literal
          RDF::Literal.new(value['value'], :language => value['xml:lang'])
        when :'typed-literal'
          RDF::Literal.new(value['value'], :datatype => value['datatype'])
        else nil
      end
    end

    ##
    # Parse NTriples data into an RDF::Enumerable
    #
    # @return [RDF::Enumerable]
    def parse_rdf(result)
      require 'rdf/ntriples' unless defined?(RDF::NTriples)
      if reader = RDF::Reader.for(:ntriples)
        reader.new(result)
      end
    end

    # Determine if a query is an ASK, SELECT, CONSTRUCT, or DESCRIBE query.
    #
    # return [:construct, :ask, :select, :describe]
    def self.query_form(query)
      # This algorithm is maybe a little overkill, but tries to avoid weirdness
      # like variables named the same as a query form by finding the first one
      # that appears with a space after it. the space after it makes it an
      # invalid URI in a prefix or base.
      raise MalformedQuery, "Missing query text" if query.nil? || query.empty?
      query_lines = query.to_s.lines.to_a
      form_line = query_lines.shift while form_line !~ /(construct|ask|describe|select)/i && query_lines.length > 0

      lowest_spot = result_form = nil
      ['construct','select','ask','describe'].each do | form |
        # catches the form on a line by itself
        return form.to_sym if form_line.downcase.chomp == form

        # otherwise, look for the form, followed by the space, and mark where it is...
        if !(spot = form_line =~ /#{form} /i).nil?
          result_form = form.to_sym
          result_form = form if !lowest_spot.nil? && lowest_spot < spot
          lowest_spot = spot if lowest_spot.nil? || spot < lowest_spot
        end
      end
      raise MalformedQuery, "Could not determine query form" if result_form.nil?
      result_form
    end

    ##
    # Returns a string representation of the repository name.
    #
    # @return [String]
    def to_s
      [account.name, name].join('/')
    end

    ##
    # @private
    # @return [Hash]
    def info
      Dydra::Client.get_json("#{@account}/#{@name}/meta")
    end

    ##
    # Uploads a local file to a temporary Amazon S3 bucket.
    #
    # @param  [String] filepath a local file path
    # @return [String] an Amazon S3 URL
    def upload_local_file(repository, filepath)
      abort "file does not exist: #{filepath}"    unless File.exists?(filepath)
      abort "file is not readable: #{filepath}"   unless File.readable?(filepath)
      abort "unknown file extension: #{filepath}" unless content_type = detect_content_type(filepath)

      stdout.puts "Preparing upload...." if self.respond_to?(:verbose) && verbose?

      # Create the boundary used in constructing the form post body
      o =  [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
      boundary = (0..9).map{ o[rand(o.length)] }.join

      # Grab required form params from the server
      upload_params = repository.s3_upload_params

      # HTTP Setup
      uri = ::URI.parse(upload_params['url'])
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      # Params order is important to AWS.
      form_data = [["key", upload_params['key']],
                   ["AWSAccessKeyId", upload_params['AWSAccessKeyId']],
                   ["acl", upload_params['acl']],
                   ["policy", upload_params['policy']],
                   ["signature", upload_params['signature']]]

      # Setup the request,
      request = Net::HTTP::Post.new(uri.request_uri)
      params = []

      # Setup the normal form params,
      form_data.each do |k, v|
        params << "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n#{v}\r\n"
      end

      # setup the file param,
      File.open(filepath) do |file|
        params << "Content-Disposition: form-data; name=\"file\"; filename=\"#{ File.basename(filepath) }\"\r\n" +
                  "Content-Type: #{ content_type }\r\n\r\n#{ file.read }\r\n"
      end

      # setup the request,
      request.content_type = "multipart/form-data; boundary=#{ boundary }"
      request.body = params.collect {|p| "--" + boundary + "\r\n" + p }.join("")  + "--" + boundary + "--"

      # and send it.
      stdout.puts "Uploading your file to S3...." if self.respond_to?(:verbose) && verbose?
      case response = http.request(request)
        when Net::HTTPSuccess
          "#{upload_params['url']}/#{upload_params['key'].gsub('${filename}', File.basename(filepath))}"
        else
          abort "unable to upload file: #{response.code} - #{response.message}"
      end
    rescue Exception => e
      abort "error during file upload: #{e.message}"
    end

    ##
    # Returns the MIME content type for the given RDF file.
    #
    # @param  [String] filepath a local file path
    # @return [String] a MIME content type, or `nil`
    def detect_content_type(filepath)
      case extname = File.extname(filepath)
        when '.ttl'  then 'text/turtle'         # Turtle
        when '.n3'   then 'text/n3'             # N3
        when '.nt'   then 'text/plain'          # N-Triples
        when '.nq'   then 'text/x-nquads'       # N-Quads
        when '.json' then 'application/json'    # RDF/JSON
        when '.rdf'  then 'application/rdf+xml' # RDF/XML
        when '.xml'  then 'application/trix'    # TriX
      end
    end
  end # Repository
end # Dydra
