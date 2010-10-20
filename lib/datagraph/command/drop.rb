module Datagraph
  class Command
    ##
    # Destroys a repository permanently.
    class Drop < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        repositories.each do |repository|
          process = repository.destroy!
          puts "Repository #{repository.url} successfully dropped." if $VERBOSE
        end
      end
    end # Drop
  end # Command
end # Datagraph
