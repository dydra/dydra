module Datagraph
  class Command
    ##
    # Deletes all data from a repository.
    class Clear < Command
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        # TODO
      end
    end # Clear
  end # Command
end # Datagraph
