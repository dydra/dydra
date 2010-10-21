module Datagraph::Client
  ##
  # Represents a Datagraph.org process.
  class Process < Resource
    SPEC = %r(^([^/]+)$) # /uuid

    # @return [String]
    attr_reader :uuid

    ##
    # @param  [String, #to_s] uuid
    def initialize(uuid)
      @uuid = uuid.to_s
      super(Datagraph::URL.join(@uuid)) # FIXME
    end

    ##
    # Returns `true` if this process is currently pending to run.
    #
    # @return [Boolean]
    def pending?
      status.eql?(:pending)
    end

    ##
    # Returns `true` if this process is currently running.
    #
    # @return [Boolean]
    def running?
      status.eql?(:running)
    end

    ##
    # Returns `true` if this process was aborted for any reason.
    #
    # @return [Boolean]
    def aborted?
      status.eql?(:aborted)
    end

    ##
    # Returns `true` if this process has already completed.
    #
    # @return [Boolean]
    def completed?
      status.eql?(:completed)
    end
    alias_method :finished?, :completed?

    ##
    # Returns `true` if this process has completed or was aborted, and
    # `false` if it's currently pending or running.
    #
    # @return [Boolean]
    def done?
      completed? || aborted?
    end

    ##
    # Returns the current status of this process.
    #
    # @return [Symbol]
    def status
      Datagraph::Client.rpc.call('datagraph.process.status', uuid).to_sym
    end

    ##
    # Returns the time when this process was submitted for execution.
    #
    # @return [Time]
    def submitted_at
      # TODO
    end

    ##
    # Returns the time when this process finished executing, or `nil` if it
    # hasn't completed yet.
    #
    # @return [Time]
    def completed_at
      # TODO
    end

    ##
    # Aborts this process.
    #
    # @return [void]
    def abort!
      Datagraph::Client.rpc.call('datagraph.process.abort', uuid)
      self
    end

    ##
    # Waits until this process is done, meanwhile calling the given `block`
    # at regular intervals.
    #
    # @param  [Hash{Symbol => Object} options
    # @option options [Float] :sleep (0.5)
    #   how many seconds to sleep before re-polling the process status
    # @return [void] self
    def wait!(options = {}, &block)
      delay = options[:sleep] || 0.5
      until done?
        yield if block_given?
        sleep delay unless delay.zero?
      end
      self
    end

    ##
    # Returns a string representation of the process ID.
    def to_s
      uuid
    end
  end # Process
end # Datagraph::Client
