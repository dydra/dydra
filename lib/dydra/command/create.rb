module Dydra
  class Command
    ##
    # Creates a new repository.
    class Create < Command
      ##
      # @param  [Array<String>] repository_specs
      # @return [void]
      def execute(*repositories)
        repositories.each do |repository|
          begin
            Repository.create!(repository)
            puts "#{repository} created."
          rescue RestClient::Forbidden
            puts "Insufficient permissions to create #{repository}."
          rescue RestClient::UnprocessableEntity
            puts "#{repository} already exists."
          end
        end
      end
    end # Create
  end # Command
end # Dydra
