module Datagraph
  class Command
    ##
    # Renames a repository.
    class Rename < Command
      def execute(old_repository_spec, new_repository_spec)
        old_repository = validate_repository_specs([old_repository_spec]).first
        new_repository = parse_repository_specs([new_repository_spec]).first
        # TODO
      end
    end # Rename
  end # Command
end # Datagraph
