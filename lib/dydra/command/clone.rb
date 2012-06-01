# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Clones a repository.
  class Clone < Command
    HELP = nil # TODO

    ##
    # @param  [String] old_repository_spec
    # @param  [String] new_repository_spec
    # @return [void]
    def execute(old_repository_spec, new_repository_spec)
      raise NotImplementedError, "#{self.class}#execute" # TODO
    end
  end # Clone
end # Dydra::Command
