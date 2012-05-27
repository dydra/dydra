# This is free and unencumbered software released into the public domain.

module Dydra
  class Command
    ##
    # Outputs the URL of an account or a repository.
    class URL < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(*resources)
        begin
          resources.each do |resource|
            if resource =~ /\//
              puts Account.new(resource).url
            else
              puts Repository.new(resource).url
            end
          end
        rescue RepositoryMisspecified => e
          puts e
        end
      end
    end # URL
  end # Command
end # Dydra
