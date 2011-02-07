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
        result = repository.query(@query, @options[:result_format])
        if @options[:result_format] == :parsed
          if result.respond_to?(:each)
            variables = result.first.each_name.to_a
            puts variables.join("\t")
            result.each do |binding|
              puts variables.map { |n| binding.to_hash[n] }.join("\t")
            end
          else
            puts bindings
          end
        else
          puts result
        end
      end

    end # Query
  end # Command
end # Dydra
