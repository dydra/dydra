module Datagraph
  ##
  # Base class for CLI commands.
  class Command
    autoload :Abort,    'datagraph/command/abort'
    autoload :Clear,    'datagraph/command/clear'
    autoload :Count,    'datagraph/command/count'
    autoload :Create,   'datagraph/command/create'
    autoload :Drop,     'datagraph/command/drop'
    autoload :Export,   'datagraph/command/export'
    autoload :Import,   'datagraph/command/import'
    autoload :List,     'datagraph/command/list'
    autoload :Open,     'datagraph/command/open'
    autoload :Query,    'datagraph/command/query'
    autoload :Register, 'datagraph/command/register'
    autoload :Rename,   'datagraph/command/rename'
    autoload :Status,   'datagraph/command/status'
    autoload :URL,      'datagraph/command/url'

    include Datagraph::Client

    def initialize(options = {})
      @options = options.dup
    end

    def basename
      RDF::CLI.basename
    end

    def verbose?
      @options[:verbose] || $VERBOSE
    end

    def debug?
      @options[:debug] || $DEBUG
    end

    def stdout
      $stdout
    end

    def stderr
      $stderr
    end

    def abort(msg)
      RDF::CLI.abort(msg)
    end

    def require_gem!(gem, msg)
      begin
        require gem
      rescue LoadError => e
        abort "#{msg} (hint: `gem install #{gem}')."
      end
    end

    def validate_repository_specs(resource_specs)
      resources = validate_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

    def validate_resource_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        case resource
          when Account
            abort "unknown account `#{resource}'" unless resource.exists?
          when Repository
            abort "unknown account `#{resource.account}'" unless resource.account.exists?
            abort "unknown repository `#{resource}'" unless resource.exists?
        end
      end
      resources
    end

    def parse_repository_specs(resource_specs)
      resources = parse_resource_specs(resource_specs)
      resources.each do |resource|
        unless resource.is_a?(Repository)
          abort "invalid repository spec `#{resource}'"
        end
      end
      resources
    end

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
end # Datagraph
