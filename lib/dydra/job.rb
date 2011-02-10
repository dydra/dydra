module Dydra
  ##
  # Represents a Dydra.com job.
  class Job < Resource
    SPEC = %r(^([^/]+)$) # /uuid

    # @return [String]
    attr_reader :uuid

    ##
    # @param  [String, #to_s] uuid
    def initialize(uuid)
      @uuid = uuid.to_s
      super(Dydra::URL.join(@uuid)) # FIXME
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
    # Returns `true` if this job was aborted for any reason.
    #
    # @return [Boolean]
    def aborted?
      status.eql?(:aborted)
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
      # TODO
    end

    ##
    # Returns the time when this job finished executing, or `nil` if it
    # hasn't completed yet.
    #
    # @return [Time]
    def completed_at
      # TODO
    end

    ##
    # Aborts this job.
    #
    # @return [void]
    def abort!
      Dydra::Client.rpc.call('dydra.job.abort', uuid)
      self
    end

    ##
    # Waits until this job is done, meanwhile calling the given `block`
    # at regular intervals.
    #
    # @param  [Hash{Symbol => Object} options
    # @option options [Float] :sleep (0.5)
    #   how many seconds to sleep before re-polling the job status
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
    # Returns a string representation of the job ID.
    def to_s
      uuid
    end
  end # Job
end # Dydra
