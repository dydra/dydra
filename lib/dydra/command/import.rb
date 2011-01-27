require "uri"
require "net/http"
require "net/https"

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
        repository = validate_repository_specs([repository_spec]).first
        urls.each do |input_url|
          stdout.puts "Importing #{input_url} into #{repository.path}..." if verbose?
          job = repository.import!(input_url)
          puts job.uuid
        end
      end

    end # Import
  end # Command
end # Dydra
