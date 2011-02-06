module Dydra
  class Command
    ##
    # Outputs the number of statements in a repository.
    class Count < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repositories)
        sum = repositories.inject(0) do |sum , repository|
          begin
            count = Repository.new(repository).info['triple_count']
            puts "#{count} #{repository}"
            sum += count
          rescue RestClient::ResourceNotFound
            puts "#{repository} not found"
          end
        end
        puts "#{sum.to_i} total"
      end
    end # Count
  end # Command
end # Dydra
