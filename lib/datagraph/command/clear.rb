module Datagraph
  class Command
    ##
    # Deletes all data from a repository.
    class Clear < Command
      def execute(*repository_specs)
        repositories = validate_repository_specs(repository_specs)
        repositories.each do |repository|
          Datagraph::Client.xmlrpc.call('datagraph.repository.clear', repository.account.name, repository.name)
          puts "Repository #{repository.url} successfully cleared." if $VERBOSE
        end
      end
    end # Clear
  end # Command
end # Datagraph
