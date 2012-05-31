# This is free and unencumbered software released into the public domain.

require 'uri'
require 'net/http'
require 'net/https'

class Dydra::Command
  ##
  # Imports data into a repository.
  class Import < Command
    BUCKET = 'tmp.datagraph.org' # an Amazon S3 bucket for temporary file uploads

    ##
    # @param  [String] repository_spec
    # @param  [Array<String>] urls
    # @return [void]
    def execute(repository_spec, *urls)
      if urls.empty?
        puts "No import URL or file specified"
        Kernel.abort
      end
      repository = Repository.new(repository_spec)
      something_suceeded = false
      urls.each do |input_url|
        begin
          stdout.puts "Importing #{input_url} into #{repository.path}..." if verbose?
          info = repository.import!(input_url, @options).wait!.info
          something_suceeded = true if info[:status] == 'completed'
          puts "#{info['status']}: #{info['message']}"
        rescue RepositoryMisspecified => e
          puts e
        rescue XMLRPC::FaultException => e
          puts e.message.sub(/Uncaught exception /,'')
        end
      end
      puts "#{repository.account}/#{repository.name} has #{repository.count} statements" if something_suceeded
    end
  end # Import
end # Dydra::Command
