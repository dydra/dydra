module Dydra
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
        job = repository.query(query)
        $stderr.puts "Query #{job} successfully submitted." if verbose? # FIXME
        #job.wait!
        $stderr.write "Query executing..." if verbose?
        $stderr.flush
        until Dydra::Client.rpc.call('dydra.job.done', job.uuid)
          $stderr.write "."
          $stderr.flush
          sleep 1.0
        end
        $stderr.puts " done." if verbose?
        begin
          case result = Dydra::Client.rpc.call('dydra.query.result', job.uuid)
            when TrueClass, FalseClass
              $stdout.puts result.inspect # @deprecated
            when Array
              require_gem! 'rdf/json', "missing RDF/JSON support"
              parser = RDF::JSON::Reader.new(StringIO.new('{}'))
              variables = result.shift.map { |variable| variable.to_sym } # the initial row contains the variable names
              solutions = result.map do |row|
                bindings = {}
                row.each_with_index do |value, index|
                  bindings[variables[index]] = parser.parse_object(value)
                end
                solution = RDF::Query::Solution.new(bindings)
              end
              $stdout.puts to_sparql_json(solutions).to_json
            else
              $stderr.puts result.inspect if debug?
          end
        rescue XMLRPC::FaultException => e # FIXME: JSON-RPC
          $stderr.puts e.message
        end
      end

      ##
      # @private
      # @see http://www.w3.org/TR/rdf-sparql-json-res/
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
                when v.datatype? then {:type => :'typed-literal', :value => v.to_s, :datatype => v.datatype.to_s}
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
end # Dydra