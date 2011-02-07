module Dydra
  class Command
    ##
    # Login and cache credentials locally
    #
    class Login < Command
      ##
      # @param  [String] account_name
      # @param  [String] password
      # @return [void]
      def execute(user = nil, pass = nil)
        while !Dydra::Client.setup?
          begin
            user = ask_for_user if user.nil?
            pass = ask_for_pass if pass.nil?
            Dydra::Client.setup!(:user => user, :pass => pass)
            token = Account.new(user).info['authentication_token']
          rescue Exception => e
            # Special case ctrl-c
            raise e if (e.is_a?(SignalException) || e.is_a?(SystemExit) )
            puts "Invalid credentials: #{e.message}"
            Dydra::Client.reset!
            user = pass = nil
            next
          end
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
        File.open(Dydra::Client.credentials_file, 'w+') { |f| f.write({ :user => user, :token => token }.to_yaml) } 
      end
    end # Register
  end # Command
end # Dydra
