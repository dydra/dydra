# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Outputs the URL of an account or a repository.
  class URL < Command
    HELP = "Outputs the URL of an account or a repository."

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
end # Dydra::Command
