# This is free and unencumbered software released into the public domain.

module Dydra
  class Command
    ##
    # Registers a new user account.
    class Register < Command
      ##
      # @param  [String] account_name
      # @param  [String] password
      # @return [void]
      def execute(account_name, password = nil)
        password ||= '' # FIXME
        account = Dydra::Account.register!(account_name, :password => password)
        puts "Account #{account.url} successfully registered." if verbose?
      end
    end # Register
  end # Command
end # Dydra
