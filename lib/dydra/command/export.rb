module Dydra
  class Command
    ##
    # Exports data from a repository in N-Triples format.
    class Export < Command
      ##
      # @param  [Array<String>] resource_specs
      # @return [void]
      def execute(*resource_specs)
        repositories = validate_repository_specs(resource_specs)
        # FIXME
        RDF::NTriples::Writer.new($stdout) do |writer|
          repositories.each do |repository|
            repository.to_rdf.each { |statement| writer << statement }
          end
        end
      end
    end # Export
  end # Command
end # Dydra
