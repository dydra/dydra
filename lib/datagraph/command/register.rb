module Datagraph
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
        account = Datagraph::Client::Account.register!(account_name, :password => password)
        puts "Account #{account.url} successfully registered." if $VERBOSE
      end
    end # Register
  end # Command
end # Datagraph
