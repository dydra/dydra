module Dydra
  ##
  # Represents a Dydra.com job.
  #
  # @see http://docs.dydra.com/sdk/ruby
  class Job < Resource
    SPEC = %r(^([^/]+)$) # /uuid

    STATUS_UNKNOWN   = :unknown
    STATUS_PENDING   = :pending
    STATUS_RUNNING   = :running
    STATUS_COMPLETED = :completed
    STATUS_FAILED    = :failed
    STATUS_ABORTED   = :aborted

    ##
    # The job UUID.
    #
    # @return [String]
    attr_reader :uuid

    ##
    # Initializes the job instance.
    #
    # @param  [String, #to_s] uuid
    #   a valid job UUID
    def initialize(uuid)
      @uuid = uuid.to_s
      super(Dydra::URL.join(@uuid)) # FIXME
    end

    ##
    # Returns a string representation of the job UUID.
    #
    # @return [String]
    def to_s
      uuid
    end

    ##
    # Returns `true` if this job is currently pending to run.
    #
    # @return [Boolean]
    def pending?
      status.eql?(:pending)
    end

    ##
    # Returns `true` if this job is currently running.
    #
    # @return [Boolean]
    def running?
      status.eql?(:running)
    end

    ##
    # Returns `true` if this job has already completed.
    #
    # @return [Boolean]
    def completed?
      status.eql?(:completed)
    end
    alias_method :finished?, :completed?

    ##
    # Returns `true` if this job failed for some reason.
    #
    # @return [Boolean]
    def failed?
      status.eql?(:failed)
    end

    ##
    # Returns `true` if this job was aborted for any reason.
    #
    # @return [Boolean]
    def aborted?
      status.eql?(:aborted)
    end

    ##
    # Returns `true` if this job has completed or was aborted, and
    # `false` if it's currently pending or running.
    #
    # @return [Boolean]
    def done?
      [:completed, :aborted, :failed].include?(status)
    end

    ##
    # Returns the current status of this job.
    #
    # @return [Symbol]
    def status
      Dydra::Client.rpc.call('dydra.job.status', uuid).to_sym
    end

    ##
    # Returns detailed information about this job.
    #
    # @return [Hash]
    def info
      Dydra::Client.rpc.call('dydra.job.info', uuid)
    end

    ##
    # Returns the time when this job was submitted for execution.
    #
    # @return [Time]
    def submitted_at
      raise NotImplementedError # TODO
    end

    ##
    # Returns the time when this job finished executing, or `nil` if it
    # hasn't completed yet.
    #
    # @return [Time]
    def completed_at
      raise NotImplementedError # TODO
    end

    ##
    # Waits until this job is done, meanwhile calling the given `block`
    # at regular intervals.
    #
    # @param  [Hash{Symbol => Object} options
    # @option options [Float] :timeout (nil)
    # @option options [Float] :sleep (0.5)
    #   how many seconds to sleep before re-polling the job status
    # @return [void] self
    def wait!(options = {}, &block)
      timeout = options[:timeout] # TODO
      delay   = options[:sleep] || 0.5
      until done?
        yield if block_given?
        sleep delay unless delay.zero?
      end
      self
    end
    alias_method :wait, :wait!

    ##
    # Aborts this job if it is currently pending or running.
    #
    # @return [void]
    def abort!
      Dydra::Client.rpc.call('dydra.job.abort', uuid)
      self
    end
    alias_method :abort, :abort!
  end # Job
end # Dydra
