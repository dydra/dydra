require 'uri'
require 'net/http'
require 'net/https'

module Dydra
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
        if urls.empty?
          puts "No import URL or file specified"
          Kernel.abort
        end
        begin
          repository = Repository.new(repository_spec)
          urls.each do |input_url|
            stdout.puts "Importing #{input_url} into #{repository.path}..." if verbose?
            repository.import!(input_url).wait!
          end
          puts "#{repository.account}/#{repository.name} has #{repository.info['triple_count']} triples"
        rescue RepositoryMisspecified => e
          puts e
        end
      end

    end # Import
  end # Command
end # Dydra
