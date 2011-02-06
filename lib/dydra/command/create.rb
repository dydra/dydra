module Dydra
  class Command
    ##
    # Creates a new repository.
    class Create < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repositories)
        repositories.each do |repository|
          Repository.create!(repository)
          puts "Repository #{repository.url} successfully created." if verbose?
        end
      end
    end # Create
  end # Command
end # Dydra
