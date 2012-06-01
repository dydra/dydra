# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Outputs the byte size of a repository.
  class Size < Command
    HELP = nil # TODO: "Outputs the byte size of a repository."

    ##
    # @param  [Array<String>] repository_specs
    # @return [void]
    def execute(*repository_specs)
      raise NotImplementedError, "#{self.class}#execute" # TODO
    end
  end # Size
end # Dydra::Command
