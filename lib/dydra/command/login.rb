module Dydra
  class Command
    ##
    # Logins and caches credentials locally.
    class Login < Command
      ##
      # @param  [String] account_name
      # @param  [String] password
      # @return [void]
      def execute(user = nil, pass = nil)
        while !Dydra::Client.setup?
          Dydra::Client.reset!
          user = pass = nil
          begin
            user = ask_for_user if user.nil?
            pass = ask_for_pass if pass.nil?
            Dydra::Client.setup!(:user => user, :pass => pass)
            token = Account.new(user).info['authentication_token']
            raise AuthenticationError, "Incorrect password" if token.nil?
          rescue RestClient::ResourceNotFound
            puts "User #{user} not found"
          rescue SignalException, SystemExit => e
            # Special case ctrl-c at the command line
            abort
          rescue Exception => e
            puts "Invalid credentials: #{e.message}"
          end
          Dydra::Client.reset! unless token
        end
        save_credentials(user, token)
        puts "Credentials saved to ~/.dydra/credentials" if verbose?
      end

      def ask_for_user
        print "Email or username: "
        $stdin.gets.strip
      end

      def ask_for_pass
        print "Password: "
        begin
          system "stty -echo"
          password = $stdin.gets.strip
          rescue Exception => e
            raise e
          ensure
            system "stty echo"
          end
        puts
        password
      end

      def save_credentials(user, token)
        require 'yaml'
        Dir.mkdir(File.dirname(Dydra::Client.credentials_file)) unless File.exists?(File.dirname(Dydra::Client.credentials_file))
        File.open(Dydra::Client.credentials_file, 'w+') { |f| f.write({ :user => user, :token => token }.to_yaml) }
      end
    end # Register
  end # Command
end # Dydra
