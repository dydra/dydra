module Datagraph
  class Command
    ##
    # Imports data into a repository.
    class Import < Command
      BUCKET = 'tmp.datagraph.org' # an Amazon S3 bucket for temporary file uploads

      ##
      # @param  [String] repository_spec
      # @param  [Array<String>] urls
      # @return [void]
      def execute(repository_spec, *urls)
        repository = validate_repository_specs([repository_spec]).first
        urls.each do |input_url|
          cloud_url = case input_url
            when %r(^(http|https|ftp)://) then input_url # already at a URL
            else upload_local_file(input_url)            # local file to be uploaded
          end
          stdout.puts "Importing #{input_url} into #{repository.path}..." if verbose?
          process = repository.import!(cloud_url)
          # TODO: wait for process completion.
        end
      end

      ##
      # Uploads a local file to a temporary Amazon S3 bucket.
      #
      # @param  [String] filepath a local file path
      # @return [String] an Amazon S3 URL
      def upload_local_file(filepath)
        require_gem! 's3',   "file uploads require the S3 gem"
        require_gem! 'uuid', "file uploads require the UUID gem"

        abort "file does not exist: #{filepath}"    unless File.exists?(filepath)
        abort "file is not readable: #{filepath}"   unless File.readable?(filepath)
        abort "unknown file extension: #{filepath}" unless content_type = detect_content_type(filepath)

        # TODO: improve this to use signed upload URLs not requiring specific credentials.
        abort "missing Amazon S3 access credentials." if ENV['AMAZON_ACCESS_KEY_ID'].to_s.empty?
        s3 = S3::Service.new({
          :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'],
        })

        stdout.puts "Uploading #{filepath} to temporary cloud storage..." if verbose?
        bucket = s3.buckets.find(BUCKET) rescue nil
        abort "temporary failure, please try again later (bucket #{BUCKET} not found)." unless bucket

        object = bucket.objects.build('import/' + UUID.generate.to_s)
        object.content      = open(filepath)
        object.content_type = content_type
        abort "file upload to #{object.url} failed." unless object.save
        object.url.to_s
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
  end # Command
end # Datagraph
