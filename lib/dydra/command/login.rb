# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Logins and caches credentials locally.
  class Login < Command
    HELP = "Caches your Dydra credentials locally."

    ##
    # @param  [String] account_name
    # @param  [String] password
    # @return [void]
    def execute(given_user = nil, given_pass = nil)
      raise NotImplementedError, "#{self.class}#execute" # TODO
    end
  end # Login
end # Dydra::Command
