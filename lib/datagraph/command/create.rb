module Datagraph
  class Command
    ##
    # Creates a new repository.
    class Create < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repository_specs)
        repositories = parse_repository_specs(repository_specs)
        repositories.each do |repository|
          repository.create!
          puts "Repository #{repository.url} successfully created." if $VERBOSE
        end
      end
    end # Create
  end # Command
end # Datagraph
