# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Renames a repository.
  class Rename < Command
    ##
    # @param  [String] old_repository_spec
    # @param  [String] new_repository_spec
    # @return [void]
    def execute(old_repository_spec, new_repository_spec)
      old_repository = validate_repository_specs([old_repository_spec]).first
      new_repository = parse_repository_specs([new_repository_spec]).first
      # TODO
    end
  end # Rename
end # Dydra::Command
