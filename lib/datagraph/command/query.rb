module Datagraph
  class Command
    ##
    # Queries a repository.
    class Query < Command
      ##
      # @param  [String] repository_spec
      # @param  [String, #to_s] query
      # @return [void]
      def execute(repository_spec, query = nil)
        repository = validate_repository_specs([repository_spec]).first
        query = case query
          when nil       then $stdin.read             # < filename.rq
          when /^@(.*)$/ then open($1) { |f| f.read } # @filename.rq, @url.rq
          else query.to_s                             # 'SELECT ...'
        end
        process = repository.query(query)
        puts "Query #{process} successfully submitted; waiting for results..." if $VERBOSE # FIXME
        process.wait!
      end
    end # Query
  end # Command
end # Datagraph
