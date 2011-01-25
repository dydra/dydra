module Dydra
  class Command
    ##
    # Shows pending, running, and completed jobs.
    class Status < Command
      ##
      # @param  [String] job_uuid
      # @return [void]
      def execute(job_uuid = nil)
        if job_uuid
          job = Job.new(job_uuid)
          case status = job.status
            when :pending
              puts "The job #{job} is currently pending to run."
            when :running
              puts "The job #{job} is currently running."
            when :aborted
              puts "The job #{job} was aborted."
            when :failed
              puts "The job #{job} failed."
            when :completed
              puts "The job #{job} has completed."
            else
              puts "The job #{job} has a status of '#{status}'."
          end
        else
          # TODO: show the status for all jobs
        end
      end
    end # Status
  end # Command
end # Dydra
