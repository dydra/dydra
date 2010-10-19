module Datagraph
  class Command
    ##
    # Registers a new user account.
    class Register < Command
      def execute(account_name, password = nil)
        password ||= '' # FIXME
        url = Datagraph::Client.xmlrpc.call('datagraph.account.register', account_name, password)
        puts "Account #{url} successfully registered." if $VERBOSE
      end
    end # Register
  end # Command
end # Datagraph
