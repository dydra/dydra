# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Opens an account or a repository in a web browser.
  class Open < Command
    HELP = "Opens an account or a repository in a web browser."

    ##
    # @param  [Array<String>] resource_specs
    # @return [void]
    def execute(*resource_specs)
      require_gem! 'launchy', "install the 'launchy' gem to use this command"
      resources = validate_resource_specs(resource_specs)
      resources.each do |resource|
        Launchy.open(resource.url)
      end
    end
  end # Open
end # Dydra::Command
