module Dydra
  class Command
    ##
    # Aborts a pending or running job.
    class Abort < Command
      ##
      # @param  [String] job_uuid
      # @return [void]
      def execute(job_uuid)
        (job = Job.new(job_uuid)).abort!
        puts "The job #{job} was successfully aborted." if verbose?
      end
    end # Abort
  end # Command
end # Dydra
