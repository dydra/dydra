# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Deletes local credentials
  class Logout < Command
    HELP = "Deletes your local credentials."

    ##
    # @return [void]
    def execute
      File.delete(Dydra::Client.credentials_file)
    end
  end # Logout
end # Dydra::Command
