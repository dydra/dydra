module Datagraph
  class Command
    ##
    # Aborts a pending or running process.
    class Abort < Command
      ##
      # @param  [String] process_uuid
      # @return [void]
      def execute(process_uuid)
        (process = Process.new(process_uuid)).abort!
        puts "The process #{process} was successfully aborted." if verbose?
      end
    end # Abort
  end # Command
end # Datagraph
