module Datagraph
  class Command
    ##
    # Outputs the number of statements in a repository.
    class Count < Command
      def execute(*resource_specs)
        repositories = validate_repository_specs(resource_specs)
        count = repositories.inject(0) do |count, repository|
          count += repository.count
        end
        puts count.to_s
      end
    end # Count
  end # Command
end # Datagraph
