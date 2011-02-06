module Dydra
  ##
  # Base class for CLI commands.
  class Command
    autoload :Abort,    'dydra/command/abort'
    autoload :Clear,    'dydra/command/clear'
    autoload :Count,    'dydra/command/count'
    autoload :Create,   'dydra/command/create'
    autoload :Drop,     'dydra/command/drop'
    autoload :Export,   'dydra/command/export'
    autoload :Import,   'dydra/command/import'
    autoload :List,     'dydra/command/list'
    autoload :Login,    'dydra/command/login'
    autoload :Logout,   'dydra/command/logout'
    autoload :Open,     'dydra/command/open'
    autoload :Query,    'dydra/command/query'
    autoload :Rename,   'dydra/command/rename'
    autoload :Status,   'dydra/command/status'
    autoload :URL,      'dydra/command/url'

    include Dydra::Client

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
            #abort "unknown account `#{resource}'" unless resource.exists? # FIXME
          when Repository
            #abort "unknown account `#{resource.account}'" unless resource.account.exists? # FIXME
            #abort "unknown repository `#{resource}'" unless resource.exists?
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
end # Dydra
