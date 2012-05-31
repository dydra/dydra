# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Deletes local credentials
  class Logout < Command
    ##
    # @return [void]
    def execute(*args)
      File.delete(Dydra::Client.credentials_file)
    end
  end # Logout
end # Dydra::Command
