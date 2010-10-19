module Datagraph
  class Command
    ##
    # Exports data from a repository in N-Triples format.
    class Export < Command
      def execute(*resource_specs)
        repositories = validate_repository_specs(resource_specs)
        RDF::NTriples::Writer.new($stdout) do |writer|
          repositories.each do |repository|
            repository.to_rdf.each { |statement| writer << statement }
          end
        end
      end
    end # Export
  end # Command
end # Datagraph
