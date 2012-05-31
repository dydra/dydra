# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Lists existing repositories.
  class List < Command
    ##
    # @param  [Array<String>] resource_specs
    # @return [void]
    def execute(user = nil)
      begin
        Repository.list(user).sort.each do |repository|
          puts repository
        end
      rescue RestClient::ResourceNotFound
        puts "#{user || $dydra[:user]} not found"
      rescue RepositoryMisspecified => e
        puts e
      end
    end
  end # List
end # Dydra::Command
