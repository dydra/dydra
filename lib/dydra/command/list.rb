# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Lists existing repositories.
  class List < Command
    HELP = "Lists your repositories."

    ##
    # @param  [Array<String>] resource_specs
    # @return [void]
    def execute(user = nil)
      begin
        Repository.list(user).sort.each do |repository|
          puts repository
        end
      rescue RestClient::ResourceNotFound
        puts "#{user || ENV['DYDRA_ACCOUNT']} not found"
      rescue RepositoryMisspecified => e
        puts e
      end
    end
  end # List
end # Dydra::Command
