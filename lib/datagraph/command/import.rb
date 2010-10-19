module Datagraph
  class Command
    ##
    # Imports data into a repository.
    class Import < Command
      def execute(resource_spec, *urls)
        repositories = validate_repository_specs([resource_spec])
        urls.each do |url|
          # TODO
        end
      end
    end # Import
  end # Command
end # Datagraph
