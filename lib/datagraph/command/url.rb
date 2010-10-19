module Datagraph
  class Command
    ##
    # Outputs the URL of an account or a repository.
    class URL < Command
      def execute(*resource_specs)
        resources = validate_resource_specs(resource_specs)
        resources.each do |resource|
          puts resource.url.to_s
        end
      end
    end # URL
  end # Command
end # Datagraph
