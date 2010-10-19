module Datagraph
  class Command
    ##
    # Lists existing repositories.
    class List < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(*resource_specs)
        resources = parse_resource_specs(resource_specs) # TODO
        Repository.each do |repository|
          puts repository.to_s
        end
      end
    end # List
  end # Command
end # Datagraph
