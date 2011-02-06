module Dydra
  class Command
    ##
    # Lists existing repositories.
    class List < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(user = nil)
        Repository.list(user).each do |repository|
          puts repository
        end
      end
    end # List
  end # Command
end # Dydra
