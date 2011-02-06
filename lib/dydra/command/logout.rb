module Dydra
  class Command
    ##
    # Delete local credentials
    class Logout < Command
      ##
      # @return [void]
      def execute(*args)
        File.delete(Dydra::Client.credentials_file)
      end
    end # Status
  end # Command
end # Dydra
