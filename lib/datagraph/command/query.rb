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
        $stderr.puts "Query #{process} successfully submitted." if verbose? # FIXME
        #process.wait!
        $stderr.write "Query executing..." if verbose?
        $stderr.flush
        until Datagraph::Client.rpc.call('datagraph.query.done', process.uuid)
          $stderr.write "."
          $stderr.flush
          sleep 1.0
        end
        $stderr.puts " done." if verbose?
        begin
          case result = Datagraph::Client.rpc.call('datagraph.query.result', process.uuid)
            when TrueClass, FalseClass
              $stdout.puts result.inspect
            when Array
              require 'rdf/json'
              parser = RDF::JSON::Reader.new(StringIO.new("{}"))
              result.each do |bindings|
                bindings.each do |k, v|
                  bindings[k] = parser.parse_object(v)
                end
                solution = RDF::Query::Solution.new(bindings)
                $stdout.puts solution.to_hash.inspect # FIXME
              end
          end
        rescue XMLRPC::FaultException => e # FIXME: JSON-RPC
          $stderr.puts e.message
        end
      end
    end # Query
  end # Command
end # Datagraph
