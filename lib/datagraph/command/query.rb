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
        $stdout.puts "Query #{process} successfully submitted." if $VERBOSE # FIXME
        #process.wait!
        $stdout.write "Query executing..." if $VERBOSE
        $stdout.flush
        until Datagraph::Client.rpc.call('datagraph.query.done', process.uuid)
          $stdout.write "."
          $stdout.flush
          sleep 1.0
        end
        $stdout.puts " done." if $VERBOSE
      end
    end # Query
  end # Command
end # Datagraph
