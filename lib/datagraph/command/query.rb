module Datagraph
  class Command
    ##
    # Queries a repository.
    class Query < Command
      def execute(repository_spec, query)
        repository = validate_repository_specs([repository_spec]).first
        # TODO
      end
    end # Query
  end # Command
end # Datagraph
