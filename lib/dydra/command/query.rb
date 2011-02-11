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
        begin
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
            if result.respond_to?(:empty?) && !result.empty?
              variables = result.first.each_name.to_a
              puts variables.join("\t")
              result.each do |binding|
                puts variables.map { |n| binding.to_hash[n] }.join("\t")
              end
            else
              puts result
            end
          else
            puts result
          end
        rescue RepositoryMisspecified => e
          puts e
        rescue RestClient::Forbidden
          puts "Insufficient permissions to query #{repository_spec}"
        rescue RestClient::ResourceNotFound
          puts "#{repository_spec} not found"
        rescue RestClient::InternalServerError => e
          puts "Internal error: #{e.response.body}"
        rescue RestClient::BadRequest => e
          puts "#{e.response.body}"
        end
      end

    end # Query
  end # Command
end # Dydra
