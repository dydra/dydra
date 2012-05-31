# This is free and unencumbered software released into the public domain.

class Dydra::Command
  ##
  # Aborts a pending or running operation.
  class Abort < Command
    HELP = "Aborts a pending or running operation."

    ##
    # @param  [String] op_uuid
    # @return [void]
    def execute(op_uuid)
      (op = Operation.new(op_uuid)).abort!
      puts "The operation #{op} was successfully aborted." if verbose?
    end
  end # Abort
end # Dydra::Command
