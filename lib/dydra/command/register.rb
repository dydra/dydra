# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Registers a new user account.
  class Register < Command
    HELP = nil # TODO

    ##
    # @param  [String] account_name
    # @param  [String] password
    # @return [void]
    def execute(account_name, password = nil)
      password ||= '' # TODO: prompt for password
      account = Dydra::Account.register!(account_name, :password => password)
      puts "Account #{account.url} successfully registered." if verbose?
    end
  end # Register
end # Dydra::Command
