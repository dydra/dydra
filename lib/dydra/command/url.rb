module Dydra
  class Command
    ##
    # Outputs the URL of an account or a repository.
    class URL < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(*resource_specs)
        resources = validate_resource_specs(resource_specs)
        resources.each do |resource|
          puts resource.url.to_s
        end
      end
    end # URL
  end # Command
end # Dydra
