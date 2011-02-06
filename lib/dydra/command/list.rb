module Dydra
  class Command
    ##
    # Lists existing repositories.
    class List < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(user = nil)
        begin
          Repository.list(user).each do |repository|
            puts repository
          end
        rescue RestClient::ResourceNotFound
          puts "#{user || $dydra[:user]} not found"
        end
      end
    end # List
  end # Command
end # Dydra
