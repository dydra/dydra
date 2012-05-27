# This is free and unencumbered software released into the public domain.

module Dydra
  class Command
    ##
    # Deletes all data from a repository.
    class Clear < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repositories)
        begin
          repositories.each do |repository|
            job = Repository.new(repository).clear!
            puts "Repository #{repository.url} successfully cleared." if verbose?
          end
        rescue RepositoryMisspecified => e
          e
        end
      end
    end # Clear
  end # Command
end # Dydra
