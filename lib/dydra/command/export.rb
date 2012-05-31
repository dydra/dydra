# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Exports data from a repository in N-Triples format.
  class Export < Command
    HELP = "Exports data from a repository in N-Triples format."

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
end # Dydra::Command
