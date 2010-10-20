module Datagraph
  class Command
    ##
    # Queries a repository.
    class Query < Command
      ##
      # @param  [String] repository_spec
      # @param  [String, #to_s] query
      # @return [void]
      def execute(repository_spec, query)
        repository = validate_repository_specs([repository_spec]).first
        process_uuid = repository.query(query)
        puts "Query #{process_uuid} successfully started." if $VERBOSE # FIXME
      end
    end # Query
  end # Command
end # Datagraph
