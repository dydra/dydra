# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Shows pending, running, and completed operations.
  class Status < Command
    HELP = "Shows pending, running, and completed operations."

    ##
    # @param  [String] op_uuid
    # @return [void]
    def execute(op_uuid = nil)
      if op_uuid
        op = Operation.new(op_uuid)
        case status = op.status
          when :pending
            puts "The operation #{op} is currently pending to run."
          when :running
            puts "The operation #{op} is currently running."
          when :aborted
            puts "The operation #{op} was aborted."
          when :failed
            puts "The operation #{op} failed."
          when :completed
            puts "The operation #{op} has completed."
          else
            puts "The operation #{op} has a status of '#{status}'."
        end
      else
        # TODO: show the status for all operations
      end
    end
  end # Status
end # Dydra::Command
