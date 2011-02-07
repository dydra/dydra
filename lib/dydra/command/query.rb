module Dydra
  class Command
    ##
    # Queries a repository.
    class Query < Command
      ##
      # @param  [String] repository_spec
      # @param  [String, #to_s] query
      # @return [void]
      def execute(repository_spec, query)
        repository = Repository.new(repository_spec)
        @query = case query
          when nil       then $stdin.read             # < filename.rq
          when /^@(.*)$/ then open($1) { |f| f.read } # @filename.rq, @url.rq
          else query.to_s                             # 'SELECT ...'
        end
        @options[:result_format] ||= :parsed
        format = @options[:result_format] == :xml ? :xml : :json
        result = repository.query(@query, format)
        if @options[:result_format] == :parsed
          require 'sparql/client'
          bindings = ::SPARQL::Client.parse_json_bindings(result)
          if bindings == true || bindings.nil?
            puts !!bindings
          else
            if !(bindings.empty?)
              variables = find_variables(bindings.first)
              puts variables.join("\t")
              bindings.each do |binding|
                puts variables.map { |n| binding.to_hash[n] }.join("\t")
              end
            end
          end
        else
          puts result
        end
      end

      ##
      # Get a list of variables for this binding
      # The variables should be obtained from the original query in the order they appear
      def find_variables(binding)
        variables = binding.each_name.to_a
        variables.sort { |a, b| @query.index("?#{a}") <=> @query.index("?#{b}") }
      end

    end # Query
  end # Command
end # Dydra
