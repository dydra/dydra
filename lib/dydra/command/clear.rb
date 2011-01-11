module Dydra
  class Command
    ##
    # Deletes all data from a repository.
    class Clear < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        repositories.each do |repository|
          process = repository.clear!
          puts "Repository #{repository.url} successfully cleared." if verbose?
        end
      end
    end # Clear
  end # Command
end # Dydra
