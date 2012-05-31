# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Deletes all data from a repository.
  class Clear < Command
    ##
    # @param  [Array<String>] repository_specs
    # @return [void]
    def execute(*repositories)
      begin
        repositories.each do |repository|
          op = Repository.new(repository).clear!
          puts "Repository #{repository.url} successfully cleared." if verbose?
        end
      rescue RepositoryMisspecified => e
        raise
      end
    end
  end # Clear
end # Dydra::Command
