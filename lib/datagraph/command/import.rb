module Datagraph
  class Command
    ##
    # Imports data into a repository.
    class Import < Command
      ##
      # @param  [String] repository_spec
      # @param  [Array<String>] urls
      # @return [void]
      def execute(repository_spec, *urls)
        repository = validate_repository_specs([repository_spec]).first
        urls.each do |url|
          puts "Importing #{url} into #{repository.url}..." if $VERBOSE
          process = repository.import!(url)
        end
      end
    end # Import
  end # Command
end # Datagraph
