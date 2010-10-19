module Datagraph
  class Command
    ##
    # Creates a new repository.
    class Create < Command
      def execute(*repository_specs)
        repositories = parse_repository_specs(repository_specs)
        repositories.each do |repository|
          url = Datagraph::Client.xmlrpc.call("datagraph.repository.create", repository.account.name, repository.name)
          puts "Repository #{url} successfully created." if $VERBOSE
        end
      end
    end # Create
  end # Command
end # Datagraph
