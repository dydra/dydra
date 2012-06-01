# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # Represents a Dydra.com API operation.
  #
  # @see http://docs.dydra.com/sdk/ruby
  class Operation < Resource
    SPEC = %r(^([^/]+)$) # /uuid

    STATUS_UNKNOWN   = :unknown
    STATUS_PENDING   = :pending
    STATUS_RUNNING   = :running
    STATUS_COMPLETED = :completed
    STATUS_FAILED    = :failed
    STATUS_ABORTED   = :aborted

    ##
    # The operation UUID.
    #
    # @return [String]
    attr_reader :uuid

    ##
    # Initializes the operation instance.
    #
    # @param  [String, #to_s] uuid
    #   a valid operation UUID
    def initialize(uuid)
      @uuid = uuid.to_s
      super(Dydra::URL.join(@uuid)) # FIXME
    end

    ##
    # Returns a string representation of the operation UUID.
    #
    # @return [String]
    def to_s
      self.uuid
    end

    ##
    # Returns `true` if this operation is currently pending to run.
    #
    # @return [Boolean]
    def pending?
      self.status.eql?(:pending)
    end

    ##
    # Returns `true` if this operation is currently running.
    #
    # @return [Boolean]
    def running?
      self.status.eql?(:running)
    end

    ##
    # Returns `true` if this operation has already completed.
    #
    # @return [Boolean]
    def completed?
      self.status.eql?(:completed)
    end
    alias_method :finished?, :completed?

    ##
    # Returns `true` if this operation failed for some reason.
    #
    # @return [Boolean]
    def failed?
      self.status.eql?(:failed)
    end

    ##
    # Returns `true` if this operation was aborted for any reason.
    #
    # @return [Boolean]
    def aborted?
      self.status.eql?(:aborted)
    end

    ##
    # Returns `true` if this operation has completed or was aborted, and
    # `false` if it's currently pending or running.
    #
    # @return [Boolean]
    def done?
      [:completed, :aborted, :failed].include?(self.status)
    end

    ##
    # Returns the current status of this operation.
    #
    # @return [Symbol]
    def status
      self.info['status'].to_sym
    end

    ##
    # Returns detailed information about this operation.
    #
    # @return [Hash]
    def info
      RPC::Client.call(:DescribeOperation, [self.uuid])
    end

    ##
    # Returns the time when this operation was submitted for execution.
    #
    # @return [Time]
    def submitted_at
      raise NotImplementedError # TODO
    end

    ##
    # Returns the time when this operation finished executing, or `nil` if it
    # hasn't completed yet.
    #
    # @return [Time]
    def completed_at
      raise NotImplementedError # TODO
    end

    ##
    # Waits until this operation is done, meanwhile calling the given `block`
    # at regular intervals.
    #
    # @param  [Hash{Symbol => Object} options
    # @option options [Float] :timeout (nil)
    # @option options [Float] :sleep (0.5)
    #   how many seconds to sleep before re-polling the operation status
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
    # Aborts this operation if it is currently pending or running.
    #
    # @return [void]
    def abort!
      RPC::Client.call(:AbortOperation, [self.uuid])
      self
    end
    alias_method :abort, :abort!
  end # Operation
end # Dydra
