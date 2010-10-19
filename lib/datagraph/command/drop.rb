module Datagraph
  class Command
    ##
    # Destroys a repository permanently.
    class Drop < Command
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        repositories.each do |repository|
          url = Datagraph::Client.xmlrpc.call("datagraph.repository.delete", repository.account.name, repository.name)
          puts "Repository successfully dropped." if $VERBOSE
        end
      end
    end # Drop
  end # Command
end # Datagraph
