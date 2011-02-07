module Dydra
  ##
  # Represents a Dydra.com RDF repository.
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$) # /account/repository

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
    # The time that the repository was first created.
    #
    # @return [DateTime]
    attr_reader :created

    ##
    # The time that the repository was last updated.
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
      raise AuthenticationError, "You must login before performing this action" if user.nil?
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
    # @param [String] repository_name
    #
    # Sugar for creating a repository, as .new instantiates an existing one.
    def self.create!(account, name = nil)
      self.new(account, name).create!
    end

    ##
    # @param [String] account
    #
    # List of repository names. Will use the given user if supplied.
    def self.list(user = nil)
      user ||= $dydra[:user]
      Dydra::Client.get_json(user + "/repositories").map { |r| r['name'] }
    end

    ##
    # Creates this repository on Dydra.com.
    #
    # @return [String] repository_name
    def create!
      Dydra::Client.post "#{account}/repositories", { :dydra_repository => { :name => name }}
    end

    ##
    # Destroys this repository from Dydra.com.
    #
    # @return [Job]
    def destroy!
      Dydra::Client.delete "#{@account}/#{@name}" 
    end

    ##
    # Deletes all data from this repository.
    # #FIXME server is not async for this method yet
    # @return [Job]
    def clear!
      Dydra::Client.rpc.call('dydra.repository.clear', path)
    end

    ##
    # Imports data from a URL into this repository.
    #
    # @param  [String, #to_s] url
    # @return [Job]
    def import!(url)
      url = case url
        when %r(^(http|https|ftp)://) then url # already at a URL
        else upload_local_file(self, url)            # local file to be uploaded
      end
      Job.new(Dydra::Client.rpc.call('dydra.repository.import', path, url.to_s))
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
    def query(query)
      Dydra::Client.post "#{account}/#{name}/sparql", { :query => query },
         :content_type => 'application/x-www-form-urlencoded', 
         :accept => 'application/sparql-results+json'
    end

    ##
    # Queries the repository, waits for the result, and returns it
    #
    # @param  [String] query
    # @return [String] RDF-JSON query results
    def query_result(query_text)
      # TODO: Separate behavior for construct/describe
      uuid = query(query_text).wait!.uuid
      sparql_json = Dydra::Client.rpc.call('dydra.query.result.json', uuid)
      results = SPARQL::Client.new("").parse_json_bindings(sparql_json).map { | result | result.to_hash }
      if results.size == 1 && results.first.keys.size == 1 && results.first.keys.first == :result
        results = results.first[:result].object if results.first[:result].respond_to?(:object)
      end
      results
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
