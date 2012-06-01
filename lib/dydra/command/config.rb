# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Displays the current configuration.
  class Config < Command
    HELP = "Displays the current configuration."

    ##
    # @return [void]
    def execute
      %w(DYDRA_ACCOUNT DYDRA_PASSWORD DYDRA_TOKEN).each do |var|
        puts "#{var}=#{ENV[var]}" if ENV.has_key?(var)
      end
    end
  end # Config
end # Dydra::Command
