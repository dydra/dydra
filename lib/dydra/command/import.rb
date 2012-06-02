# This is free and unencumbered software released into the public domain.

require 'uri'
require 'net/http'
require 'net/https'

class Dydra::Command
  ##
  # Imports data into a repository.
  class Import < Command
    HELP = "Imports data into a repository."
    BUCKET = 'tmp.datagraph.org' # an Amazon S3 bucket for temporary file uploads

    ##
    # @param  [String] repository_spec
    # @param  [Array<String>] urls
    # @return [void]
    def execute(repository_spec, *urls)
      if urls.empty?
        puts "No import URL or file specified"
        Kernel.abort
      end
      repository = Repository.new(repository_spec)
      something_suceeded = false
      urls.each do |input_url|
        begin
          stdout.puts "Importing #{input_url} into #{repository.path}..." if verbose?
          info = repository.import!(input_url, @options).wait!.info
          something_suceeded = true if info[:status] == 'completed'
          puts "#{info['status']}: #{info['message']}"
        rescue RepositoryMisspecified => e
          puts e
        rescue XMLRPC::FaultException => e
          puts e.message.sub(/Uncaught exception /,'')
        end
      end
      puts "#{repository.account}/#{repository.name} has #{repository.count} statements" if something_suceeded
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
    # Returns params necessary to generate an S3 upload form
    #
    # @return [Hash]
    def s3_upload_params
      raise NotImplementedError, "#{self.class}#s3_upload_params" # TODO
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
  end # Import
end # Dydra::Command
