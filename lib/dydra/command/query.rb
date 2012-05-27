# This is free and unencumbered software released into the public domain.

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

          @options[:result_format] ||= case Repository.query_form(query)
            when :select, :ask
              :parsed
            when :construct, :describe
              :turtle
          end

          result = repository.query(@query, :format => @options[:result_format])

          if @options[:result_format] == :parsed && result.respond_to?(:empty?) && !result.empty?
            variables = result.first.each_name.to_a
            puts variables.join("\t")
            result.each do |binding|
              puts variables.map { |n| binding.to_hash[n] }.join("\t")
            end
          else
            puts result
          end
        rescue RestClient::NotAcceptable
          puts "Invalid result format: #{@options[:result_format]} for #{Repository.query_form(query)}"
        end
      end

    end # Query
  end # Command
end # Dydra
