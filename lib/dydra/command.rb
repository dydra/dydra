# This is free and unencumbered software released into the public domain.

module Dydra
  ##
  # Base class for CLI commands.
  class Command
    autoload :Abort,    'dydra/command/abort'
    autoload :Clear,    'dydra/command/clear'
    autoload :Clone,    'dydra/command/clone'
    autoload :Config,   'dydra/command/config'
    autoload :Count,    'dydra/command/count'
    autoload :Create,   'dydra/command/create'
    autoload :Drop,     'dydra/command/drop'
    autoload :Export,   'dydra/command/export'
    autoload :Help,     'dydra/command/help'
    autoload :Import,   'dydra/command/import'
    autoload :List,     'dydra/command/list'
    autoload :Login,    'dydra/command/login'
    autoload :Logout,   'dydra/command/logout'
    autoload :Open,     'dydra/command/open'
    autoload :Query,    'dydra/command/query'
    autoload :Register, 'dydra/command/register'
    autoload :Rename,   'dydra/command/rename'
    autoload :Size,     'dydra/command/size'
    autoload :Status,   'dydra/command/status'
    autoload :URL,      'dydra/command/url'

    include Dydra

    ##
    # Returns the arity of this command class.
    #
    # @return [Integer]
    def self.arity
      self.instance_method(:execute).arity
    end

    ##
    # @param  [Hash] options
    def initialize(options = {})
      @options = options.dup
    end

    ##
    # @return [Boolean]
    def verbose?
      @options[:verbose] || $VERBOSE || debug?
    end

    ##
    # @return [Boolean]
    def debug?
      @options[:debug] || $DEBUG
    end

    ##
    # The arity of this command.
    #
    # @return [Integer]
    # @!parse attr_reader :arity
    def arity
      self.method(:execute).arity
    end

    ##
    # @return [String]
    # @!parse attr_reader :basename
    def basename
      RDF::CLI.basename
    end

    ##
    # @return [IO]
    # @!parse attr_reader :stdout
    def stdout
      @stdout ||= @options[:stdout] || $stdout
    end

    ##
    # @return [IO]
    # @!parse attr_reader :stderr
    def stderr
      @stderr ||= @options[:stderr] || $stderr
    end

    ##
    # @param  [Array<#to_s>] msgs
    # @return [void]
    def puts(*msgs)
      self.stdout.puts(*msgs)
    end

    ##
    # @param  [#to_s] msg
    # @return [void]
    def warn(msg)
      self.stderr.warn(msg)
    end

    ##
    # @param  [#to_s] msg
    # @return [void]
    def abort(msg)
      RDF::CLI.abort(msg.to_s)
    end

    ##
    # @param  [#to_s] gem
    # @return [void]
    def require_gem!(gem, msg)
      begin
        require gem
      rescue LoadError => e
        abort "#{msg} (hint: `gem install #{gem}')."
      end
    end

    ##
    # @private
    def validate_repository_specs(resource_specs)
      resources = validate_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

    ##
    # @private
    def validate_resource_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        case resource
          when Account
            #abort "unknown account `#{resource}'" unless resource.exists? # FIXME
          when Repository
            #abort "unknown account `#{resource.account}'" unless resource.account.exists? # FIXME
            #abort "unknown repository `#{resource}'" unless resource.exists?
        end
      end
      resources
    end

    ##
    # @private
    def parse_repository_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

    ##
    # @private
    def parse_resource_specs(resource_specs)
      resources = []
      resource_specs.each do |resource_spec|
        unless resource = Resource.new(resource_spec)
          abort "invalid resource spec `#{resource_spec}'"
        end
        resources << resource
      end
      resources
    end
  end # Command
end # Dydra
