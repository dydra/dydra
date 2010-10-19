module Datagraph
  class Command
    ##
    # Outputs the number of statements in a repository.
    class Count < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        count = repositories.inject(0) do |count, repository|
          count += repository.count
        end
        puts count.to_s
      end
    end # Count
  end # Command
end # Datagraph
