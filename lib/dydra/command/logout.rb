# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Deletes local credentials
  class Logout < Command
    HELP = "Deletes your local credentials."

    ##
    # @return [void]
    def execute
      File.delete(File.join(ENV['HOME'], '.dydra', 'credentials'))
      File.delete(File.join(ENV['HOME'], '.dydra', 'environment'))
    end
  end # Logout
end # Dydra::Command
