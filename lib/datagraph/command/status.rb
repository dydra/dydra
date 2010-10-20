module Datagraph
  class Command
    ##
    # Shows pending, running, and completed processes.
    class Status < Command
      ##
      # @param  [String] process_uuid
      # @return [void]
      def execute(process_uuid = nil)
        if process_uuid
          case status = Process.new(process_uuid).status
            when :pending
              puts "The process #{process} is currently pending to run."
            when :running
              puts "The process #{process} is currently running."
            when :aborted
              puts "The process #{process} was aborted."
            when :completed
              puts "The process #{process} has completed."
            else
              puts "The process #{process} has a status of '#{status}'."
          end
        else
          # TODO: show the status for all processes
        end
      end
    end # Status
  end # Command
end # Datagraph
