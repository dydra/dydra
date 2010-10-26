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
              solutions = result.map do |bindings|
                bindings.each do |k, v|
                  bindings[k] = parser.parse_object(v)
                end
                solution = RDF::Query::Solution.new(bindings)
              end
              $stdout.puts to_sparql_json(solutions).to_json
          end
        rescue XMLRPC::FaultException => e # FIXME: JSON-RPC
          $stderr.puts e.message
        end
      end

      ##
      # @private
      def to_sparql_json(solutions)
        json = {:head => {:vars => []}, :results => {:bindings => []}}
        solutions.each do |solution|
          solution.each_name do |k|
            json[:head][:vars] << k unless json[:head][:vars].include?(k)
          end
          json[:results][:bindings] << solution.to_hash.each.inject({}) do |bindings, (k, v)|
            bindings.merge(k => case v
              when RDF::Node     then {:type => :bnode, :value => v.id.to_s}
              when RDF::URI      then {:type => :uri, :value => v.to_s}
              when RDF::Literal  then case
                when v.datatype? then {:type => :literal, :value => v.to_s, :datatype => v.datatype.to_s}
                when v.language? then {:type => :literal, :value => v.to_s, 'xml:lang' => v.language.to_s}
                else {:type => :literal, :value => v.to_s}
              end
            end)
          end
        end
        json
      end
    end # Query
  end # Command
end # Datagraph
